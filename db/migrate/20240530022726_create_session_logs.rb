class CreateSessionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :session_logs do |t|
      t.references :session, foreign_key: true
      t.integer :scene
      t.string :role
      t.string :template
      t.string :content
      t.json :tool_calls
      t.string :tool_call_id

      t.timestamps
    end
  end
end
