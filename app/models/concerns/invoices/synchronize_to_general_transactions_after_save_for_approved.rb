# frozen_string_literal: true

module Invoices
  module SynchronizeToGeneralTransactionsAfterSaveForApproved extend ActiveSupport::Concern
    included do
      after_save :synchronize_to_general_transactions_after_save_for_approved
    end

    def synchronize_to_general_transactions_after_save_for_approved
      @general_transaction_after_save_for_approved = self.general_transactions
        .find_or_initialize_by(source: :invoice_approved)
      @general_transaction_after_save_for_approved.assign_attributes(
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
      if @general_transaction_after_save_for_approved.new_record?
        @general_transaction_after_save_for_approved.number_evidence = GeneralTransaction
          .retrieve_new_number_evidence(self.ba.contract.location, :bj)
        @general_transaction_after_save_for_approved.company = Company.bpi
      end
      @general_transaction_after_save_for_approved.save! if @general_transaction_after_save_for_approved.new_record? || @general_transaction_after_save_for_approved.changed?

      credit_cost_center_for_fine_reduction_if_fine_exist! # OK
      debit_bymhd_for_fine_reduction_if_fine_exist! # OK

      debit_bymhd! # OK
      credit_cost_center_for_ppn_if_biaya_and_ppn_include! # OK
      debit_ppn_if_biaya! # OK
      debit_cost_center_for_ppn_if_non_biaya! # OK

      credit_debt! # OK
      if self.pph_id.present?
        credit_pph! # OK
      end

      credit_cost_center_for_rounding_if_rounded! # OK
      # debit_bymhd_for_rounding_if_rounded! # OK
    end

    # TODO: ...
    def accrued_journals
      @accrued_journals ||= Journal
        .where('description ILIKE ?', "%[#{self.id}]%")
        .reorder(created_at: :asc)
    end

    def credit_debt!
      accrued_credit_gt_line.save! if accrued_credit_gt_line.new_record? || accrued_credit_gt_line.changed?
    end
    def debit_bymhd!
      accrued_debit_gt_line.save! if accrued_debit_gt_line.new_record? || accrued_debit_gt_line.changed?
    end
    def debit_ppn_if_biaya!
      if ppn_cost_biaya?
        accrued_debit_ppn_gt_line.save! if accrued_debit_ppn_gt_line.new_record? || accrued_debit_ppn_gt_line.changed?
        return
      end
      @general_transaction_after_save_for_approved
        .general_transaction_lines.debit
        .where('description ILIKE ?', "%[PPN 25140]")
        .destroy_all
    end
    def debit_cost_center_for_ppn_if_non_biaya!
      if ppn_cost_non_biaya? && ppn_exclude?
        accrued_debit_cost_center_ppn_non_biaya.save! if accrued_debit_cost_center_ppn_non_biaya.new_record? || accrued_debit_cost_center_ppn_non_biaya.changed?
        return
      end
      @general_transaction_after_save_for_approved
        .general_transaction_lines.debit
        .where('description ILIKE ?', "%[PPN Exclude & PPN Cost Center]")
        .destroy_all
    end
    def credit_cost_center_for_ppn_if_biaya_and_ppn_include!
      if ppn_cost_biaya? && ppn_include?
        accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.save! if accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.new_record? || accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.changed?
        return
      end
      @general_transaction_after_save_for_approved
        .general_transaction_lines.credit
        .where('description ILIKE ?', "%[Kredit Cost Center of PPN Include]")
        .destroy_all
    end
    def credit_pph!
      accrued_credit_pph_gt_line.save! if accrued_credit_pph_gt_line.new_record? || accrued_credit_pph_gt_line.changed?
    end

    def accrued_credit_gt_line
      return @accrued_credit_gt_line if @accrued_credit_gt_line.present?
      @accrued_credit_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :credit)
        .where('description ILIKE ?', "%[Akrual Hutang]")
        .first
      if !@accrued_credit_gt_line.present?
        @accrued_credit_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :credit,
            description: "Jurnal akrual atas Hutang #{self.ba.description} #{self.ba.contract.client.name} [Akrual Hutang]"
          )
      end

      idr = (self.dpp_price + self.ppn_price - self.pph_price)
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @accrued_credit_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.accrued_credit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @accrued_credit_gt_line
    end
    def accrued_debit_ppn_gt_line
      return @accrued_debit_ppn_gt_line if @accrued_debit_ppn_gt_line.present?
      @accrued_debit_ppn_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :debit)
        .where('description ILIKE ?', "%[PPN 25140]")
        .first
      if !@accrued_debit_ppn_gt_line.present?
        @accrued_debit_ppn_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :debit,
            description: "Jurnal PPN #{self.ppn * 100}% #{self.ba.description} #{self.ba.contract.client.name} [PPN 25140]"
          )
      end

      idr = self.ppn_price
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @accrued_debit_ppn_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: Account.find_by(code: '25140').code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @accrued_debit_ppn_gt_line
    end
    def accrued_debit_cost_center_ppn_non_biaya
      return @accrued_debit_cost_center_ppn_non_biaya if @accrued_debit_cost_center_ppn_non_biaya.present?
      @accrued_debit_cost_center_ppn_non_biaya = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :debit)
        .where('description ILIKE ?', "%[PPN Exclude & PPN Cost Center]")
        .first
      if !@accrued_debit_cost_center_ppn_non_biaya.present?
        @accrued_debit_cost_center_ppn_non_biaya = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :debit,
            description: "Jurnal PPN pada Cost Center #{self.ba.description} #{self.ba.contract.client.name} [PPN Exclude & PPN Cost Center]"
          )
      end

      idr = self.ppn_price
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @accrued_debit_cost_center_ppn_non_biaya.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ba.contract.accrued_debit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @accrued_debit_cost_center_ppn_non_biaya
    end
    def accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include
      return @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include if @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.present?
      @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :credit)
        .where('description ILIKE ?', "%[Kredit Cost Center of PPN Include]")
        .first
      if !@accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.present?
        @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :credit,
            description: "Jurnal balik atas perpindahan nilai PPN Include #{self.ba.description} #{self.ba.contract.client.name} [Kredit Cost Center of PPN Include]"
          )
      end

      idr = self.ppn_price
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ba.contract.accrued_debit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include
    end

    def accrued_debit_gt_line
      return @accrued_debit_gt_line if @accrued_debit_gt_line.present?
      @accrued_debit_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :debit)
        .where('description ILIKE ?', "%[BYMHD ke Hutang]")
        .first
      if !@accrued_debit_gt_line.present?
        @accrued_debit_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :debit,
            description: "Jurnal balik BYMHD ke Hutang #{self.ba.description} #{self.ba.contract.client.name} [BYMHD ke Hutang]"
          )
      end

      idr = self.ba.price - self.fine.to_money
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @accrued_debit_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ba.accrued_credit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @accrued_debit_gt_line
    end

    def credit_cost_center_for_fine_reduction_if_fine_exist!
      if fine.present? && fine > 0
        credit_cost_center_for_fine_reduction_gt_line.save! if credit_cost_center_for_fine_reduction_gt_line.new_record? || credit_cost_center_for_fine_reduction_gt_line.changed?
        return
      end
      @general_transaction_after_save_for_approved
        .general_transaction_lines.credit
        .where('description ILIKE ?', "%[PENGEMBALIAN ATAS DENDA]")
        .destroy_all
    end
    def debit_bymhd_for_fine_reduction_if_fine_exist!
      if fine.present? && fine > 0
        debit_bymhd_for_fine_reduction_gt_line.save! if debit_bymhd_for_fine_reduction_gt_line.new_record? || debit_bymhd_for_fine_reduction_gt_line.changed?
        return
      end
      @general_transaction_after_save_for_approved
        .general_transaction_lines.debit
        .where('description ILIKE ?', "%[PENGEMBALIAN ATAS DENDA]")
        .destroy_all
    end

    def credit_cost_center_for_fine_reduction_gt_line
      return @credit_cost_center_for_fine_reduction_gt_line if @credit_cost_center_for_fine_reduction_gt_line.present?
      @credit_cost_center_for_fine_reduction_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :credit)
        .where('description ILIKE ?', "%[PENGEMBALIAN ATAS DENDA]")
        .first
      if !@credit_cost_center_for_fine_reduction_gt_line.present?
        @credit_cost_center_for_fine_reduction_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :credit,
            description: "Jurnal balik atas denda #{self.ba.description} #{self.ba.contract.client.name} [PENGEMBALIAN ATAS DENDA]"
          )
      end

      idr = self.fine
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @credit_cost_center_for_fine_reduction_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ba.contract.accrued_debit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @credit_cost_center_for_fine_reduction_gt_line
    end

    def debit_bymhd_for_fine_reduction_gt_line
      return @debit_bymhd_for_fine_reduction_gt_line if @debit_bymhd_for_fine_reduction_gt_line.present?
      @debit_bymhd_for_fine_reduction_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :debit)
        .where('description ILIKE ?', "%[PENGEMBALIAN ATAS DENDA]")
        .first
      if !@debit_bymhd_for_fine_reduction_gt_line.present?
        @debit_bymhd_for_fine_reduction_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :debit,
            description: "Jurnal balik atas denda #{self.ba.description} #{self.ba.contract.client.name} [PENGEMBALIAN ATAS DENDA]"
          )
      end

      idr = self.fine
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @debit_bymhd_for_fine_reduction_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ba.accrued_credit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @debit_bymhd_for_fine_reduction_gt_line
    end

    def credit_cost_center_for_rounding_if_rounded!
      if is_dpp_rounded?
        credit_cost_center_for_rounding_gt_line.save! if credit_cost_center_for_rounding_gt_line.new_record? || credit_cost_center_for_rounding_gt_line.changed?
        return
      end
      @general_transaction_after_save_for_approved
        .general_transaction_lines.credit
        .where('description ILIKE ?', "%[Pembulatan Cost Center]")
        .destroy_all
    end

    def debit_bymhd_for_rounding_if_rounded!
      if is_dpp_rounded?
        debit_bymhd_for_rounding_gt_line.save! if debit_bymhd_for_rounding_gt_line.new_record? || debit_bymhd_for_rounding_gt_line.changed?
        return
      end
      @general_transaction_after_save_for_approved
        .general_transaction_lines.debit
        .where('description ILIKE ?', "%[Pembulatan BYMHD]")
        .destroy_all
    end

    def credit_cost_center_for_rounding_gt_line
      return @credit_cost_center_for_rounding_gt_line if @credit_cost_center_for_rounding_gt_line.present?
      @credit_cost_center_for_rounding_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :credit)
        .where('description ILIKE ?', "%[Pembulatan Cost Center]")
        .first
      if !@credit_cost_center_for_rounding_gt_line.present?
        @credit_cost_center_for_rounding_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :credit,
            description: "Jurnal penyesuaian atas pembulatan #{self.ba.description} #{self.ba.contract.client.name} [Pembulatan Cost Center]"
          )
      end

      idr = 1.to_money
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @credit_cost_center_for_rounding_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ba.contract.accrued_debit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @credit_cost_center_for_rounding_gt_line
    end
    def debit_bymhd_for_rounding_gt_line
      return @debit_bymhd_for_rounding_gt_line if @debit_bymhd_for_rounding_gt_line.present?
      @debit_bymhd_for_rounding_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :debit)
        .where('description ILIKE ?', "%[Pembulatan BYMHD]")
        .first
      if !@debit_bymhd_for_rounding_gt_line.present?
        @debit_bymhd_for_rounding_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :debit,
            description: "Jurnal penyesuaian atas pembulatan #{self.ba.description} #{self.ba.contract.client.name} [Pembulatan BYMHD]"
          )
      end

      idr = 1.to_money
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @debit_bymhd_for_rounding_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.ba.accrued_credit.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @debit_bymhd_for_rounding_gt_line
    end

    def accrued_credit_pph_gt_line
      return @accrued_credit_pph_gt_line if @accrued_credit_pph_gt_line.present?
      @accrued_credit_pph_gt_line = @general_transaction_after_save_for_approved
        .general_transaction_lines
        .where(group: :credit)
        .where('description ILIKE ?', "%[PPH]")
        .first
      if !@accrued_credit_pph_gt_line.present?
        @accrued_credit_pph_gt_line = @general_transaction_after_save_for_approved
          .general_transaction_lines.new(
            group: :credit,
            description: "Jurnal PPH #{self.pph_percentage}% #{self.pph.name} #{self.ba.description} #{self.ba.contract.client.name} [PPH]"
          )
      end

      idr = self.pph_price
      usd = (idr / @general_transaction_after_save_for_approved.rate_money).to_money.with_currency(:usd)
      @accrued_credit_pph_gt_line.assign_attributes(
        price_idr: idr,
        price_usd: usd,
        code: self.pph.code,
        rate: @general_transaction_after_save_for_approved.rate_money,
      )
      @accrued_credit_pph_gt_line
    end





    # def synchronize_to_general_transactions_after_save_for_approved
      # return unless approved?

      # # 1. FINE
      # apply_for_fine_reduction_if_exist
      # # 1.1. Kredit Cost Center dengan nilai Denda
      # #   credit_cost_center_for_fine_reduction_if_fine_exist!
      # # 1.2. Debit BYMHD dengan nilai Denda
      # #   debit_bymhd_for_fine_reduction_if_fine_exist!

      # # 2. Jurnal Balik BYMHD
      # debit_bymhd!

      # # IF PPN Exclude
      # #   IF PPN masuk ke: 25140 / Biaya
      # #     3. Debit 25140 sebesar nilai PPN dari DPP
      # #   ELSE IF PPN masuk ke: Cost Center / Non-Biaya
      # #     3. Debit Cost Center sebesar nilai PPN dari DPP
      # # ELSE IF PPN Include
      # #   IF PPN masuk ke: 25140 / Biaya
      # #     3. Kredit Cost Center sebesar nilai PPN dari DPP
      # #     4. Debit 25140 sebesar nilai PPN dari DPP
      # #   ELSE IF PPN masuk ke: Cost Center / Non-Biaya
      # #     3. Do Nothing

      # credit_cost_center_for_ppn_if_biaya_and_ppn_include!
      # debit_ppn_if_biaya!
      # debit_cost_center_for_ppn_if_non_biaya!

      # credit_debt!
      # if self.pph_id.present?
        # credit_pph!
      # end

      # credit_cost_center_for_rounding_if_rounded!
      # debit_bymhd_for_rounding_if_rounded!
    # end
    # def apply_for_fine_reduction_if_exist
      # # if
      # credit_cost_center_for_fine_reduction
      # debit_bymhd_for_fine_reduction
    # end
  end
end
