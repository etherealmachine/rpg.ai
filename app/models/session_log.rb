# == Schema Information
#
# Table name: session_logs
#
#  id         :integer          not null, primary key
#  deleted    :boolean
#  request    :json
#  response   :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  session_id :integer
#
# Indexes
#
#  index_session_logs_on_session_id  (session_id)
#
# Foreign Keys
#
#  session_id  (session_id => sessions.id)
#
class SessionLog < ApplicationRecord
  belongs_to :session
end
