class CreateEnumPrices < (Rails.version < '5.1') ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :prices do |t|
      t.references :enumerations
      t.float :price
    end
    add_index :prices, :enumerations_id
  end
end
