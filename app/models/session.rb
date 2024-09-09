# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Session < ApplicationRecord
  has_many :session_logs

  after_initialize :custom_initialization
  attr_reader :log, :state, :objects

  def custom_initialization
    @log = []
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:access_token]
    )
    #@model = 'gpt-3.5-turbo-0125'
    @model = 'gpt-4o-2024-05-13'
    @state = RpgAi::State.new
    @objects = RpgAi::Objects.new
    session_logs.each do |entry|
      entry.request.dig('messages').map do |msg|
        msg.symbolize_keys
      end.filter do |msg|
        msg[:role] == 'user'
      end.each do |msg|
        @log << msg.transform_values(&:to_sym)
      end
      handle_response(entry.response)
    end
  end

  def handle_response(response)
    choice = response.dig('choices', 0)
    finish_reason = choice.dig('finish_reason')
    message = choice.dig('message')
    if message['content']
      @log << {
        role: :assistant,
        content: message['content'],
      }
    end
    (message['tool_calls'] || []).filter do |call|
      call.dig('type') == 'function'
    end.each do |call|
      id = call.dig('id')
      method = call.dig('function', 'name')
      params = JSON.parse(call.dig('function', 'arguments'))
      result = state.method(method).call(params.symbolize_keys)
      @log << {
        role: :assistant,
        tool_calls: [{
          id:,
          function: {
            name: method,
            arguments: params.to_json,
          },
          type: 'function',
        }]
      }
      @log << {
        tool_call_id: id,
        role: :tool,
        name: method,
        content: result,
      }
    end
  end

  def status
    return :initial if log.empty?
    return :awaiting_player_input if log.last[:role] == :assistant
    return :tool_result if log.last[:role] == :tool
    return :unknown
  end

  def prompt(input)
    request = {
      model: @model,
      messages: messages(input),
      temperature: 0.7,
      tools: state.class.published_function_specs
    }
    response = @client.chat(parameters: request)
    handle_response(response)
    session_logs.create(request:, response:)
  end

  def messages(input)
    messages = [
      { role: :system, content: RpgAi::Templates.system.result_with_hash(objects.current) },
      { role: :system, content: RpgAi::Templates.object_description.result_with_hash(objects.current) },
    ].concat(@log)
    if input.present?
      messages << { role: :user, content: input }
    end
    case status
    when :initial
      messages << { role: :system, content: RpgAi::Templates.generate_npc_description.result_with_hash(objects.current) }
    when :awaiting_player_input
      messages << { role: :system, content: RpgAi::Templates.classify_response.result_with_hash(objects.current) }
    when :tool_result
    end
    messages
  end

  def clear!
    session_logs.update_all(deleted: true)
  end

  def cost
    session_logs.map do |entry|
      input_tokens = entry.response.dig('usage', 'prompt_tokens') || 0
      output_tokens = entry.response.dig('usage', 'completion_tokens') || 0
      model = entry.response.dig('model')
      next 0 unless model && (input_tokens || output_tokens)
      coeffs = case model
      when 'gpt-3.5-turbo-0125'
        [0.5, 1.5]
      when 'gpt-4o-2024-05-13'
        [5.0, 15.0]
      else
        return "Unknown model #{model}"
      end
      input_tokens*(coeffs[0]/1_000_000) + output_tokens*(coeffs[1]/1_000_000)
    end.sum
  end

end