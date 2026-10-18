class CreateConversions < ActiveRecord::Migration[8.1]
  def change
    create_table :conversions do |t|
      t.string :title

      t.timestamps
    end
  end
end
