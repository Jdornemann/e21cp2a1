class AddUserToBillings < ActiveRecord::Migration[5.1]
  def change
    add_column :billings, :user, :string
  end
end
