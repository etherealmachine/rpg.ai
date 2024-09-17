# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  cost       :decimal(, )
#  state      :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Session < ApplicationRecord
  has_many :logs, foreign_key: 'session_id', class_name: 'SessionLog'

  after_initialize :custom_initialization

  def custom_initialization
    @log = []
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:access_token]
    )
    @model = 'gpt-4o-mini-2024-07-18'
    #@model = 'gpt-4o-2024-08-06'
    @state = RpgAi::State.from_json(self.state)
  end

  def scene_logs
    logs.where(scene: @state.scenes.count)
  end

  def handle_response(response)
    choice = response.dig('choices', 0)
    finish_reason = choice.dig('finish_reason') # stop, length, function_call, content_filter, null
    message = choice.dig('message')
    if message['content']
      logs << begin
        SessionLog.new(
          scene: @state.scenes.count,
          role: :assistant,
          content: @state.handle_response(JSON.parse(message['content']).with_indifferent_access),
        )
      rescue JSON::ParserError
        SessionLog.new(
          scene: @state.scenes.count,
          role: :assistant,
          content: message['content'],
        )
      end
    end
    tool_calls = (message['tool_calls'] || []).filter do |call|
      call.dig('type') == 'function'
    end
    if tool_calls.present?
      logs << SessionLog.new(
        scene: @state.scenes.count,
        role: :assistant,
        tool_calls: tool_calls
      )
    end
    tool_calls.each do |call|
      id = call.dig('id')
      method = call.dig('function', 'name')
      params = JSON.parse(call.dig('function', 'arguments'))
      result = @state.method(method).call(params.symbolize_keys)
      logs << SessionLog.new(
        # Really ugly
        scene: @state.scenes.count - (method == 'change_scene' && result.include?('changed') ? 1 : 0),
        role: :tool,
        content: result.as_json,
        tool_call_id: id,
      )
    end
  end

  def status
    return :initial if scene_logs.empty?
    return :pending_classification if scene_logs.last[:role] == 'user'
    return :awaiting_player_input if scene_logs.last[:role] == 'assistant'
    return :tool_result if scene_logs.last[:role] == 'tool'
    return :unknown
  end

  def prompt(input, recursive: false)
    logs << SessionLog.new(
      scene: @state.scenes.count,
      role: :user,
      content: input,
    ) if input.present?
    response = @client.chat(parameters: request(input))
    puts(response) # TODO: Handle errors
    handle_response(response)
    self.update_attribute(:state, @state.to_json)
    self.update_attribute(:cost, (cost || 0) + calculate_cost(response))
    if status == :tool_result
      raise 'Recursive prompting' if recursive
      prompt(nil, recursive: true)
    end
  end

  def request(input)
    if status == :pending_classification
      {
        model: @model,
        messages: messages(input),
        temperature: 0.7,
        tools: @state.class.published_function_specs,
        tool_choice: :required,
      }
    else
      {
        model: @model,
        messages: messages(input),
        temperature: 0.7,
        response_format: {
          type: :json_schema,
          json_schema: {
            name: :state_response,
            schema: @state.response_schema,
            strict: true,
          },
        },
      }
    end
  end

  def messages(input)
    messages = [
      { role: :system, template: :system },
    ].concat(scene_logs.map do |log|
      { role: log.role, content: log.content, tool_calls: log.tool_calls, tool_call_id: log.tool_call_id }.compact
    end)
    if input.present?
      messages << { role: :user, content: input }
    end
    case status
    when :initial
      messages << { role: :system, template: :initial}
    when :pending_classification
      messages << { role: :system, template: :classify_response }
    when :tool_result
    end
    messages.filter { |msg| msg[:template].present? }.each do |msg|
      msg[:content] = RpgAi::Templates.get(msg[:template]).result_with_hash({
        state: @state,
      })
    end
    messages
  end

  def clear!
    logs.destroy_all
    self.update_attribute(:state, nil)
  end

  def calculate_cost(response)
    input_tokens = response.dig('usage', 'prompt_tokens') || 0
    output_tokens = response.dig('usage', 'completion_tokens') || 0
    model = response.dig('model')
    return 0 unless model && (input_tokens || output_tokens)
    coeffs = case model
    when 'gpt-4o-mini-2024-07-18'
      [0.15, 0.60]
    when 'gpt-4o-2024-08-06'
      [2.50, 10.0]
    else
      throw "Unknown model #{model}"
    end
    input_tokens*(coeffs[0]/1_000_000) + output_tokens*(coeffs[1]/1_000_000)
  end

end
