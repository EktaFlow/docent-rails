class CreateAssessments < ActiveRecord::Migration[7.0]
  def change
    create_table :assessments do |t|
      t.string :name
      t.text :scope
      t.integer :target_mrl
      t.integer :current_mrl
      t.boolean :level_switching
      t.date :target
      t.string :location
      t.string :deskbook_version

      t.timestamps
    end
  end
end
