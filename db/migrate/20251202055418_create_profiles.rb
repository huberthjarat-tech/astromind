class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :birth_datetime
      t.string :birth_city
      t.string :birth_country
      t.text :natal_chart_text

      t.timestamps
    end
  end
end
