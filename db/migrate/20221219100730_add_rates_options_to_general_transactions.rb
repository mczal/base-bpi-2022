class AddRatesOptionsToGeneralTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :general_transactions, :rates_source, :string
    add_column :general_transactions, :rates_group, :string
    add_column :general_transactions, :input_option, :string

    # end_of_period_rates_options: {
    #   month: ,
    #   year:
    # }
    add_column :general_transactions, :end_of_period_rates_options, :json, default: {}

    # fixed_rates_options: {
    #   rate_id: ,
    #   price:
    # }
    add_column :general_transactions, :fixed_rates_options, :json, default: {}
  end
end
