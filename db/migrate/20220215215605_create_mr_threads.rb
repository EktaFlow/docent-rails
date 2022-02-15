class CreateMrThreads < ActiveRecord::Migration[7.0]
  def change
    create_table :mr_threads do |t|
      t.string :name
      t.integer :mr_level
      t.timestamps
    end
  end
end
