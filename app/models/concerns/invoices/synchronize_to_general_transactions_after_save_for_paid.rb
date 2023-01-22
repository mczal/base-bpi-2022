# frozen_string_literal: true

module Invoices
  module SynchronizeToGeneralTransactionsAfterSaveForPaid extend ActiveSupport::Concern
    included do
      after_save :synchronize_to_general_transactions_after_save_for_paid
    end

    def synchronize_to_general_transactions_after_save_for_paid
      return unless paid?
      @general_transaction_after_save_for_paid = self.general_transactions
        .find_or_initialize_by(source: :invoice_paid)
      @general_transaction_after_save_for_paid.assign_attributes(
        date: self.date,
        location: self.ba.contract.location,
        input_option: self.ba.contract.price_currency.downcase,
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
          .retrieve_new_number_evidence(self.ba.contract.location, :cash, cash_account: self.bank_account)
        @general_transaction_after_save_for_paid.company = Company.bpi
      end
      @general_transaction_after_save_for_paid.save! if @general_transaction_after_save_for_paid.new_record? || @general_transaction_after_save_for_paid.changed?

      debit_debt!
      credit_bank!
    end

    def accrued_journals
      @accrued_journals ||= Journal
        .where('description ILIKE ?', "%[#{self.id}]%")
        .reorder(created_at: :asc)
    end

    def debit_debt!
      realized_debit_gt_line.save! if realized_debit_gt_line.new_record? || realized_debit_gt_line.changed?
    end
    def credit_bank!
      realized_credit_gt_line.save! if realized_credit_gt_line.new_record? || realized_credit_gt_line.changed?
    end

    def realized_debit_gt_line
      return @realized_debit_gt_line if @realized_debit_gt_line.present?
      @realized_debit_gt_line = @general_transaction_after_save_for_paid
        .general_transaction_lines
        .where(group: :debit)
        .where('description ILIKE ?', "%[Jurnal Balik Hutang]")
        .first
      if !@realized_debit_gt_line.present?
        @realized_debit_gt_line = @general_transaction_after_save_for_paid
          .general_transaction_lines.new(
            group: :debit,
            description: "Jurnal Realisasi Pembayaran #{self.ba.description} #{self.ba.contract.client.name} [Jurnal Balik Hutang]"
          )
      end

      idr = (self.dpp_price + self.ppn_price - self.pph_price)
      usd = (idr / @general_transaction_after_save_for_paid.rate_money).to_money.with_currency(:usd)
      @realized_debit_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.accrued_credit.code,
        rate: @general_transaction_after_save_for_paid.rate_money,
      )
      @realized_debit_gt_line
    end
    def realized_credit_gt_line
      return @realized_credit_gt_line if @realized_credit_gt_line.present?
      @realized_credit_gt_line = @general_transaction_after_save_for_paid
        .general_transaction_lines
        .where(group: :credit)
        .where('description ILIKE ?', "%[KAS]")
        .first
      if !@realized_credit_gt_line.present?
        @realized_credit_gt_line = @general_transaction_after_save_for_paid
          .general_transaction_lines.new(
            group: :credit,
            description: "Jurnal Realisasi Pembayaran #{self.ba.description} #{self.ba.contract.client.name} [KAS]"
          )
      end

      idr = (self.dpp_price + self.ppn_price - self.pph_price)
      usd = (idr / @general_transaction_after_save_for_paid.rate_money).to_money.with_currency(:usd)
      @realized_credit_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.bank_account.code,
        rate: @general_transaction_after_save_for_paid.rate_money,
      )
      @realized_credit_gt_line
    end
  end
end
