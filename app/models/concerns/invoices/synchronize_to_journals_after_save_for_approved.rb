# frozen_string_literal: true

module Invoices
  module SynchronizeToJournalsAfterSaveForApproved extend ActiveSupport::Concern
    included do
      after_save :synchronize_to_journals_after_save_for_approved
    end

    def synchronize_to_journals_after_save_for_approved
      return unless approved?
      credit_cost_center_for_fine_reduction_if_fine_exist!
      debit_bymhd_for_fine_reduction_if_fine_exist!

      debit_bymhd!
      credit_cost_center_for_ppn_if_biaya_and_ppn_include!
      debit_ppn_if_biaya!
      debit_cost_center_for_ppn_if_non_biaya!

      credit_debt!
      if self.pph_id.present?
        credit_pph!
      end

      credit_cost_center_for_rounding_if_rounded!
      debit_bymhd_for_rounding_if_rounded!
    end

    def accrued_journals
      @accrued_journals ||= Journal
        .where('description ILIKE ?', "%[#{self.id}]%")
        .reorder(created_at: :asc)
    end

    def credit_debt!
      accrued_credit_journal.save! if accrued_credit_journal.new_record? || accrued_credit_journal.changed?
    end
    def debit_bymhd!
      accrued_debit_journal.save! if accrued_debit_journal.new_record? || accrued_debit_journal.changed?
    end
    def debit_ppn_if_biaya!
      if ppn_cost_biaya?
        accrued_debit_ppn_journal.save! if accrued_debit_ppn_journal.new_record? || accrued_debit_ppn_journal.changed?
        return
      end
      Journal.where(
        record_id: self.id,
        record_class: self.class.to_s,
        type_journal: :credit,
      ).where(
        'description ILIKE ?', "%[#{self.id}][PPN]%"
      ).destroy_all
    end
    def debit_cost_center_for_ppn_if_non_biaya!
      if ppn_cost_non_biaya? && ppn_exclude?
        accrued_debit_cost_center_ppn_non_biaya.save! if accrued_debit_cost_center_ppn_non_biaya.new_record? || accrued_debit_cost_center_ppn_non_biaya.changed?
        return
      end
      Journal.where(
        record_id: self.id,
        record_class: self.class.to_s,
        type_journal: :credit,
      ).where(
        'description ILIKE ?', "%[#{self.id}][NON_BIAYA_PPN]%"
      ).destroy_all
    end
    def credit_cost_center_for_ppn_if_biaya_and_ppn_include!
      if ppn_cost_biaya? && ppn_include?
        if accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.new_record? ||
            accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.changed?
          accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.save!
        end
        return
      end
      Journal.where(
        record_id: self.id,
        record_class: self.class.to_s,
        type_journal: :credit,
      ).where(
        'description ILIKE ?', "%[#{self.id}][BIAYA_PPN][PPN_INCLUDE][SWITCH_VALUE_TO_PPN_BIAYA]%"
      ).destroy_all
    end
    def credit_pph!
      accrued_credit_pph_journal.save! if accrued_credit_pph_journal.new_record? || accrued_credit_pph_journal.changed?
    end

    def accrued_credit_journal
      return @accrued_credit_journal if @accrued_credit_journal.present?
      @accrued_credit_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][AR]%"
        ).first
      if !@accrued_credit_journal.present?
        @accrued_credit_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][AR]<br/>#{self.ba.description}"
        )
      end

      @accrued_credit_journal.assign_attributes(
        price: (self.dpp_price + self.ppn_price - self.pph_price),
        number_evidence: self.ref_number,
        account_id: self.accrued_credit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_credit_journal
    end
    def accrued_debit_ppn_journal
      return @accrued_debit_ppn_journal if @accrued_debit_ppn_journal.present?
      @accrued_debit_ppn_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][PPN]%"
        ).first
      if !@accrued_debit_ppn_journal.present?
        @accrued_debit_ppn_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][PPN]<br/>#{self.ba.description}"
        )
      end

      @accrued_debit_ppn_journal.assign_attributes(
        price: self.ppn_price,
        number_evidence: self.ref_number,
        account_id: Account.find_by(code: '25140').id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_debit_ppn_journal
    end
    def accrued_debit_cost_center_ppn_non_biaya
      return @accrued_debit_cost_center_ppn_non_biaya if @accrued_debit_cost_center_ppn_non_biaya.present?
      @accrued_debit_cost_center_ppn_non_biaya = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][NON_BIAYA_PPN]%"
        ).first
      if !@accrued_debit_cost_center_ppn_non_biaya.present?
        @accrued_debit_cost_center_ppn_non_biaya = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][NON_BIAYA_PPN]<br/>#{self.ba.description}"
        )
      end

      @accrued_debit_cost_center_ppn_non_biaya.assign_attributes(
        price: self.ppn_price,
        number_evidence: self.ref_number,
        account_id: self.ba.contract.accrued_debit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_debit_cost_center_ppn_non_biaya
    end
    def accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include
      return @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include if @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.present?
      @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][BIAYA_PPN][PPN_INCLUDE][SWITCH_VALUE_TO_PPN_BIAYA]%"
        ).first
      if !@accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.present?
        @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include= Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][BIAYA_PPN][PPN_INCLUDE][SWITCH_VALUE_TO_PPN_BIAYA]<br/>#{self.ba.description}"
        )
      end

      @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include.assign_attributes(
        price: self.ppn_price,
        number_evidence: self.ref_number,
        account_id: self.ba.contract.accrued_debit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_credit_cost_center_for_ppn_if_biaya_and_ppn_include
    end

    def accrued_debit_journal
      return @accrued_debit_journal if @accrued_debit_journal.present?
      @accrued_debit_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][AR]%"
        ).first
      if !@accrued_debit_journal.present?
        @accrued_debit_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][AR]<br/>#{self.ba.description}"
        )
      end

      @accrued_debit_journal.assign_attributes(
        price: self.ba.price - self.fine.to_money,
        number_evidence: self.ref_number,
        account_id: self.ba.accrued_credit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_debit_journal
    end

    def credit_cost_center_for_fine_reduction_if_fine_exist!
      if fine.present? && fine > 0
        credit_cost_center_for_fine_reduction_journal.save! if credit_cost_center_for_fine_reduction_journal.new_record? || credit_cost_center_for_fine_reduction_journal.changed?
        return
      end
      Journal.where(
        record_id: self.id,
        record_class: self.class.to_s,
        type_journal: :credit,
      ).where(
        'description ILIKE ?', "%[#{self.id}][PENGEMBALIAN ATAS DENDA]%"
      ).destroy_all
    end
    def debit_bymhd_for_fine_reduction_if_fine_exist!
      if fine.present? && fine > 0
        debit_bymhd_for_fine_reduction_journal.save! if debit_bymhd_for_fine_reduction_journal.new_record? || debit_bymhd_for_fine_reduction_journal.changed?
        return
      end
      Journal.where(
        record_id: self.id,
        record_class: self.class.to_s,
        type_journal: :debit,
      ).where(
        'description ILIKE ?', "%[#{self.id}][PENGEMBALIAN ATAS DENDA]%"
      ).destroy_all
    end

    def credit_cost_center_for_fine_reduction_journal
      return @credit_cost_center_for_fine_reduction_journal if @credit_cost_center_for_fine_reduction_journal.present?
      @credit_cost_center_for_fine_reduction_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][PENGEMBALIAN ATAS DENDA]%"
        ).first
      if !@credit_cost_center_for_fine_reduction_journal.present?
        @credit_cost_center_for_fine_reduction_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][PENGEMBALIAN ATAS DENDA]<br/>Pengembalian Saldo atas Denda #{self.ba.description}"
        )
      end

      @credit_cost_center_for_fine_reduction_journal.assign_attributes(
        price: self.fine,
        number_evidence: self.ref_number,
        account_id: self.ba.contract.accrued_debit_id,
        date: self.created_at.localtime.to_date,
      )
      @credit_cost_center_for_fine_reduction_journal
    end

    def debit_bymhd_for_fine_reduction_journal
      return @debit_bymhd_for_fine_reduction_journal if @debit_bymhd_for_fine_reduction_journal.present?
      @debit_bymhd_for_fine_reduction_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][PENGEMBALIAN ATAS DENDA]%"
        ).first
      if !@debit_bymhd_for_fine_reduction_journal.present?
        @debit_bymhd_for_fine_reduction_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][PENGEMBALIAN ATAS DENDA]<br/>Pengembalian Saldo atas Denda #{self.ba.description}"
        )
      end

      @debit_bymhd_for_fine_reduction_journal.assign_attributes(
        price: self.fine,
        number_evidence: self.ref_number,
        account_id: self.ba.accrued_credit_id,
        date: self.created_at.localtime.to_date,
      )
      @debit_bymhd_for_fine_reduction_journal
    end

    def credit_cost_center_for_rounding_if_rounded!
      if is_dpp_rounded?
        credit_cost_center_for_rounding_journal.save! if credit_cost_center_for_rounding_journal.new_record? || credit_cost_center_for_rounding_journal.changed?
        return
      end
      Journal.where(
        record_id: self.id,
        record_class: self.class.to_s,
        type_journal: :credit,
      ).where(
        'description ILIKE ?', "%[#{self.id}][PEMBULATAN]%"
      ).destroy_all
    end

    def debit_bymhd_for_rounding_if_rounded!
      if is_dpp_rounded?
        debit_bymhd_for_rounding_journal.save! if debit_bymhd_for_rounding_journal.new_record? || debit_bymhd_for_rounding_journal.changed?
        return
      end
      Journal.where(
        record_id: self.id,
        record_class: self.class.to_s,
        type_journal: :debit,
      ).where(
        'description ILIKE ?', "%[#{self.id}][PEMBULATAN]%"
      ).destroy_all
    end

    def credit_cost_center_for_rounding_journal
      return @credit_cost_center_for_rounding_journal if @credit_cost_center_for_rounding_journal.present?
      @credit_cost_center_for_rounding_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][PEMBULATAN]%"
        ).first
      if !@credit_cost_center_for_rounding_journal.present?
        @credit_cost_center_for_rounding_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][PEMBULATAN]<br/>Pengembalian Saldo atas Pembulatan #{self.ba.description}"
        )
      end

      @credit_cost_center_for_rounding_journal.assign_attributes(
        price: 1.to_money,
        number_evidence: self.ref_number,
        account_id: self.ba.contract.accrued_debit_id,
        date: self.created_at.localtime.to_date,
      )
      @credit_cost_center_for_rounding_journal
    end
    def debit_bymhd_for_rounding_journal
      return @debit_bymhd_for_rounding_journal if @debit_bymhd_for_rounding_journal.present?
      @debit_bymhd_for_rounding_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][PEMBULATAN]%"
        ).first
      if !@debit_bymhd_for_rounding_journal.present?
        @debit_bymhd_for_rounding_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][PEMBULATAN]<br/>Pengembalian Saldo atas Pembulatan #{self.ba.description}"
        )
      end

      @debit_bymhd_for_rounding_journal.assign_attributes(
        price: 1.to_money,
        number_evidence: self.ref_number,
        account_id: self.ba.contract.accrued_credit_id,
        date: self.created_at.localtime.to_date,
      )
      @debit_bymhd_for_rounding_journal
    end

    def accrued_credit_pph_journal
      return @accrued_credit_pph_journal if @accrued_credit_pph_journal.present?
      @accrued_credit_pph_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][PPH]%"
        ).first
      if !@accrued_credit_pph_journal.present?
        @accrued_credit_pph_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][PPH]<br/>#{self.ba.description}"
        )
      end

      @accrued_credit_pph_journal.assign_attributes(
        price: self.pph_price,
        number_evidence: self.ref_number,
        account_id: self.pph_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_credit_pph_journal
    end
  end
end
