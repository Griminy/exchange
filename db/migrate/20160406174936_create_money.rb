class CreateMoney < ActiveRecord::Migration
  def change
    create_table :money do |t|
      t.integer :quantity
      t.integer :sum_of_coint
    end
  end
end
