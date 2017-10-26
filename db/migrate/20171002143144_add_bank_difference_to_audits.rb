class AddBankDifferenceToAudits < ActiveRecord::Migration[5.1]
  def change
    rename_column :audits, :difference, :bank_difference
    add_column :audits, :difference, :decimal, precision: 20, scale: 2, default: 0.0
  end
end
