class AddNumberEvidenceToRevals < ActiveRecord::Migration[6.1]
  def change
    add_column :revals, :number_evidence, :string
  end
end
