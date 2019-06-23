class AddUserIdToBillings < ActiveRecord::Migration[5.1]
  def change
    add_column :billings, :user_id, :integer
  end
end
