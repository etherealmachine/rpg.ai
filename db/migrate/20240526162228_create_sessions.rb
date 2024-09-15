class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.numeric :cost

      t.timestamps
    end
  end
end
