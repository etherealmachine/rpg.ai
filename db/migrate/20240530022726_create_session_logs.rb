class CreateSessionLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :session_logs do |t|
      t.references :session, foreign_key: true
      t.json :request
      t.json :response
      t.boolean :deleted

      t.timestamps
    end
  end
end
