class CreateReadings < ActiveRecord::Migration[7.1]
  def change
    create_table :readings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :reading_type
      t.string :category_tarot
      t.date :date
      t.text :content

      t.timestamps
    end
  end
end
