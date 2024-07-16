class AddColumnRecipientToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :recipient, :string
  end
end
