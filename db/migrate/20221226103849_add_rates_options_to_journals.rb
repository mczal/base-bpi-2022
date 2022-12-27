class AddRatesOptionsToJournals < ActiveRecord::Migration[6.1]
  def change
    add_column :journals, :rates_options, :json, default: {}
  end
end
