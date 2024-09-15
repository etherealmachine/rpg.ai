# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  cost       :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class SessionTest < ActiveSupport::TestCase
  def setup
    openai_client = Minitest::Mock.new
    def openai_client.chat(parameters: nil)
      last = parameters[:messages].last
      JSON.parse(case
      when last[:template] == :generate_description
        {
          choices: [{
            finish_reason: 'stop',
            message: {
              content: 'Some response',
            },
          }]
        }
      when last[:template] == :classify_response
        {
          choices: [{
            finish_reason: 'stop',
            message: {
              tool_calls: [{
                id: '1',
                type: 'function',
                function: {
                  name: 'interrogate_npc',
                  arguments: {}.to_json,
                },
              }],
            },
          }]
        }
      when last[:role] == 'tool'
        {
          choices: [{
            finish_reason: 'stop',
            message: {
              content: 'Response based on tool output',
            },
          }]
        }
      else
        raise "unexpected last message #{last.to_json}"
      end.to_json)
    end
    OpenAI::Client.stub :new, openai_client do
      @session = Session.create
    end
  end

  test "creating a new session" do
    assert_equal @session.status, :initial
  end

  test "player input" do
    @session.prompt(nil)
    assert_equal :awaiting_player_input, @session.status
    @session.prompt('some example player input')
    assert_equal :tool_result, @session.status
    @session.prompt(nil)
    assert_equal :awaiting_player_input, @session.status
    @session.prompt('more player input')
    assert_equal :tool_result, @session.status
    @session.prompt(nil)
    assert_equal :awaiting_player_input, @session.status
    binding.pry
  end
end
