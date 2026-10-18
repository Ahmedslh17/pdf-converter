class RemoveImageFromConversions < ActiveRecord::Migration[8.1]
  def change
    remove_column :conversions, :image, :string
  end
end
