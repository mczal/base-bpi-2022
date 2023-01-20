module Bas
  module SynchronizeToGeneralTransactionsAfterSave extend ActiveSupport::Concern
    include DateHelper

    included do
      after_save :synchronize_to_general_transactions_after_save
    end

    def synchronize_to_general_transactions_after_save
      general_transaction.assign_attributes(gt_params)
      general_transaction.save!
    end

    def general_transaction
      @general_transaction ||= GeneralTransaction.find_or_initialize_by(
        transactionable_id: self.id,
        transactionable_type: self.class.to_s,
        company: Company.bpi
      )
    end

    def gt_params
      {
        date: self.date,
        number_evidence: GeneralTransaction.retrieve_new_number_evidence(self.contract.location, :bj),
        location: self.contract.location,
        input_option: self.contract.price_currency.downcase,
        rates_source: :bank_of_indonesia,
        rates_group: :fixed_rates,
        # status: :accepted,
        source: :ba,
        fixed_rates_options: {
          id: latest_rate_instance_in_date.id
        },
        general_transaction_lines_attributes: gtl_params
      }
    end
    def gtl_params
      [
        {
          group: :debit,
          code: self.contract.accrued_debit.code,
          is_master_business_units_enabled: self.contract.is_master_business_units_enabled,
          master_business_unit_id: self.contract.master_business_unit_id,
          master_business_unit_location_id: self.contract.master_business_unit_location_id,
          master_business_unit_area_id: self.contract.master_business_unit_area_id,
          master_business_unit_activity_id: self.contract.master_business_unit_activity_id,
          description: "Akrual biaya #{self.description} #{self.contract.client.name} - Periode #{readable_date_5 self.date}",
          price_idr: self.price,
          price_usd: price_usd,
          rate: latest_rate_instance_in_date.middle,
        },
        {
          group: :credit,
          code: self.accrued_credit.code,
          description: "Akrual biaya #{self.description} #{self.contract.client.name} - Periode #{readable_date_5 self.date}",
          price_idr: self.price,
          price_usd: price_usd,
          rate: latest_rate_instance_in_date.middle,
        },
      ]
    end

    def price_usd
      (self.price / self.latest_rate_instance_in_date.middle).to_money.with_currency(:usd)
    end
    def latest_rate_instance_in_date
      Rate.latest_rate_instance_in(
        month: self.date.month,
        year: self.date.year,
        origin: :bank_of_indonesia
      )
    end
  end
end
