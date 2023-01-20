# frozen_string_literal: true

module Invoices
  module SynchronizeToJournalsAfterSaveForPaid extend ActiveSupport::Concern
    included do
      after_save :synchronize_to_journals_after_save_for_paid
    end

    def synchronize_to_journals_after_save_for_paid
      return unless paid?
      debit_debt!
      credit_bank!
    end

    def accrued_journals
      @accrued_journals ||= Journal
        .where('description ILIKE ?', "%[#{self.id}]%")
        .reorder(created_at: :asc)
    end

    def debit_debt!
      realized_debit_journal.save! if realized_debit_journal.new_record? || realized_debit_journal.changed?
    end
    def credit_bank!
      realized_credit_journal.save! if realized_credit_journal.new_record? || realized_credit_journal.changed?
    end

    def realized_debit_journal
      return @realized_debit_journal if @realized_debit_journal.present?
      @realized_debit_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][P]%"
        ).first
      if !@realized_debit_journal.present?
        @realized_debit_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][P]<br/>#{self.ba.description}"
        )
      end

      @realized_debit_journal.assign_attributes(
        price: (self.dpp_price + self.ppn_price - self.pph_price),
        number_evidence: self.ref_number,
        account_id: self.accrued_credit_id,
        date: self.created_at.localtime.to_date,
      )
      @realized_debit_journal
    end
    def realized_credit_journal
      return @realized_credit_journal if @realized_credit_journal.present?
      @realized_credit_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}][P]%"
        ).first
      if !@realized_credit_journal.present?
        @realized_credit_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.ba_id}][#{self.id}][P]<br/>#{self.ba.description}"
        )
      end

      @realized_credit_journal.assign_attributes(
        price: (self.dpp_price + self.ppn_price - self.pph_price),
        number_evidence: self.ref_number,
        account_id: self.bank_account_id,
        date: self.created_at.localtime.to_date,
      )
      @realized_credit_journal
    end
  end
end
