class AddBankDifferenceToAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :bank_difference, :decimal, precision: 20, scale: 2
  end
end
