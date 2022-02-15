class CreateSubthreads < ActiveRecord::Migration[7.0]
  def change
    create_table :subthreads do |t|
      t.string :name
      t.timestamps
    end
  end
end
