# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  cost       :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Session < ApplicationRecord
  has_many :logs, foreign_key: 'session_id', class_name: 'SessionLog'

  after_initialize :custom_initialization
  attr_reader :state

  def custom_initialization
    @log = []
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:access_token]
    )
    #@model = 'gpt-3.5-turbo-0125'
    @model = 'gpt-4o-2024-05-13'
    @state = RpgAi::State.new
  end

  def handle_response(response)
    choice = response.dig('choices', 0)
    finish_reason = choice.dig('finish_reason') # stop, length, function_call, content_filter, null
    message = choice.dig('message')
    if message['content']
      logs << SessionLog.new(
        role: :assistant,
        content: message['content'],
      )
    end
    tool_calls = (message['tool_calls'] || []).filter do |call|
      call.dig('type') == 'function'
    end
    if tool_calls.present?
      logs << SessionLog.new(role: :assistant, tool_calls: tool_calls)
    end
    tool_calls.each do |call|
      id = call.dig('id')
      method = call.dig('function', 'name')
      params = JSON.parse(call.dig('function', 'arguments'))
      result = state.method(method).call(params.symbolize_keys)
      logs << SessionLog.new(
        role: :tool,
        content: result.as_json,
        tool_call_id: id,
      )
    end
  end

  def status
    return :initial if logs.empty?
    return :pending_classification if logs.last[:role] == 'system'
    return :awaiting_player_input if logs.last[:role] == 'assistant'
    return :tool_result if logs.last[:role] == 'tool'
    return :unknown
  end

  def prompt(input)
    request = {
      model: @model,
      messages: messages(input),
      temperature: 0.7,
      tools: state.class.published_function_specs
    }
    logs << SessionLog.new(
      role: :user,
      content: input,
    ) if input.present?
    response = @client.chat(parameters: request)
    handle_response(response)
    self.update_attribute(:cost, (cost || 0) + calculate_cost(response))
  end

  def messages(input)
    messages = [
      { role: :system, template: :system },
      { role: :system, template: :object_description },
    ].concat(logs)
    if input.present?
      messages << { role: :user, content: input }
    end
    case status
    when :initial
      messages << { role: :system, template: :generate_description }
    when :awaiting_player_input
      messages << { role: :system, template: :classify_response }
    when :tool_result
    end
    messages.filter { |msg| msg[:template].present? }.each do |msg|
      msg[:content] = RpgAi::Templates.get(msg[:template]).result_with_hash(state.current)
    end
    messages
  end

  def clear!
    logs.destroy_all
  end

  def calculate_cost(response)
    input_tokens = response.dig('usage', 'prompt_tokens') || 0
    output_tokens = response.dig('usage', 'completion_tokens') || 0
    model = response.dig('model')
    return 0 unless model && (input_tokens || output_tokens)
    coeffs = case model
    when 'gpt-3.5-turbo-0125'
      [0.5, 1.5]
    when 'gpt-4o-2024-05-13'
      [5.0, 15.0]
    else
      return "Unknown model #{model}"
    end
    input_tokens*(coeffs[0]/1_000_000) + output_tokens*(coeffs[1]/1_000_000)
  end

end
