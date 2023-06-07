# frozen_string_literal: true

module InvoiceDirectExternals
  module SynchronizeToGeneralTransactionsAfterSaveForPaid extend ActiveSupport::Concern
    included do
      after_save :synchronize_to_general_transactions_after_save_for_paid
    end

    def synchronize_to_general_transactions_after_save_for_paid
      return unless paid? || ok?
      @general_transaction_after_save_for_paid = self.general_transactions
        .find_or_initialize_by(source: :invoice_direct_external_paid)
      @general_transaction_after_save_for_paid.assign_attributes(
        date: self.date,
        location: self.location,
        input_option: self.price_currency.downcase,
        rates_source: :bank_of_indonesia,
        rates_group: :fixed_rates,
        fixed_rates_options: { id: Rate.latest_rate_instance_in(
          month: self.date.month,
          year: self.date.year,
          origin: :bank_of_indonesia
        ).id },
      )
      if @general_transaction_after_save_for_paid.new_record?
        @general_transaction_after_save_for_paid.number_evidence = GeneralTransaction
          .retrieve_new_number_evidence(self.location, :cash, cash_account: self.bank_account)
        @general_transaction_after_save_for_paid.company = Company.bpi
      end
      @general_transaction_after_save_for_paid.save! if @general_transaction_after_save_for_paid.new_record? || @general_transaction_after_save_for_paid.changed?

      debit_cost_center!
      debit_ppn_if_ppn_biaya!
      credit_bank!
    end

    def debit_cost_center!
      realized_debit_gt_line.save! if realized_debit_gt_line.new_record? || realized_debit_gt_line.changed?
    end
    def debit_ppn_if_ppn_biaya!
      if self.ppn_cost_biaya?
        realized_debit_ppn_biaya_gt_line.save! if realized_debit_ppn_biaya_gt_line.new_record? || realized_debit_ppn_biaya_gt_line.changed?
      else
        @general_transaction_after_save_for_paid
          .general_transaction_lines
          .where(group: :debit)
          .where('description ILIKE ?', "%[PPN]")
          .destroy_all
      end
    end
    def credit_bank!
      realized_credit_gt_line.save! if realized_credit_gt_line.new_record? || realized_credit_gt_line.changed?
    end

    def realized_debit_gt_line
      return @realized_debit_gt_line if @realized_debit_gt_line.present?
      @realized_debit_gt_line = @general_transaction_after_save_for_paid
        .general_transaction_lines
        .where(group: :debit)
        .where('description NOT ILIKE ?', "%[PPN]")
        .first
      if !@realized_debit_gt_line.present?
        @realized_debit_gt_line = @general_transaction_after_save_for_paid
          .general_transaction_lines.new(
            group: :debit,
            description: self.description
          )
      end

      # idr = (self.dpp_price + self.ppn_price)
      if faktur_pajak_checked?
        if ppn_cost_non_biaya?
          idr = (self.dpp_price + self.ppn_price)
        elsif ppn_cost_biaya?
          idr = self.dpp_price
        end
      else
        idr = self.dpp_price
      end

      usd = (idr / @general_transaction_after_save_for_paid.rate_money).to_money.with_currency(:usd)
      @realized_debit_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.cost_center.code,
        rate: @general_transaction_after_save_for_paid.rate_money,
        description: self.description,
        is_master_business_units_enabled: self.is_master_business_units_enabled,
        master_business_unit_id: self.master_business_unit_id,
        master_business_unit_location_id: self.master_business_unit_location_id,
        master_business_unit_area_id: self.master_business_unit_area_id,
        master_business_unit_activity_id: self.master_business_unit_activity_id,
      )
      @realized_debit_gt_line
    end
    def realized_debit_ppn_biaya_gt_line
      return @realized_debit_ppn_biaya_gt_line if @realized_debit_ppn_biaya_gt_line.present?
      @realized_debit_ppn_biaya_gt_line = @general_transaction_after_save_for_paid
        .general_transaction_lines
        .where(group: :debit)
        .where('description ILIKE ?', "%[PPN]")
        .first
      if !@realized_debit_ppn_biaya_gt_line.present?
        @realized_debit_ppn_biaya_gt_line = @general_transaction_after_save_for_paid
          .general_transaction_lines.new(
            group: :debit,
            description: "#{self.description} [PPN]"
          )
      end

      idr = self.ppn_price
      usd = (idr / @general_transaction_after_save_for_paid.rate_money).to_money.with_currency(:usd)
      @realized_debit_ppn_biaya_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ppn_biaya_account.code,
        rate: @general_transaction_after_save_for_paid.rate_money,
        description: "#{self.description} [PPN]"
      )
      @realized_debit_ppn_biaya_gt_line
    end

    def realized_credit_gt_line
      return @realized_credit_gt_line if @realized_credit_gt_line.present?
      @realized_credit_gt_line = @general_transaction_after_save_for_paid
        .general_transaction_lines
        .where(group: :credit)
        .first
      if !@realized_credit_gt_line.present?
        @realized_credit_gt_line = @general_transaction_after_save_for_paid
          .general_transaction_lines.new(
            group: :credit,
            description: self.description
          )
      end

      idr = (self.dpp_price + self.ppn_price)
      usd = (idr / @general_transaction_after_save_for_paid.rate_money).to_money.with_currency(:usd)
      @realized_credit_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.bank_account.code,
        rate: @general_transaction_after_save_for_paid.rate_money,
        description: self.description
      )
      @realized_credit_gt_line
    end
  end
end
