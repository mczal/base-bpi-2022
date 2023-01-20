# frozen_string_literal: true

module Bas
  module SynchronizeToJournalsAfterSave extend ActiveSupport::Concern
    included do
      # after_save :synchronize_to_journals_after_save
    end

    def synchronize_to_journals_after_save
      accrued_debit_journal.save! if accrued_debit_journal.new_record? || accrued_debit_journal.changed?
      accrued_credit_journal.save! if accrued_credit_journal.new_record? || accrued_credit_journal.changed?
    end

    def accrued_journals
      @accrued_journals ||= Journal
        .where('description ILIKE ?', "%[#{self.id}]%")
        .reorder(created_at: :asc)
    end

    def accrued_credit_journal
      return @accrued_credit_journal if @accrued_credit_journal.present?
      @accrued_credit_journal = Journal
        .where(
          journalable_id: self.id,
          journalable_type: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}]%"
        ).first
      if !@accrued_credit_journal.present?
        @accrued_credit_journal = Journal.new(
          journalable_id: self.id,
          journalable_type: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.id}]<br/>#{self.description}"
        )
      end

      @accrued_credit_journal.assign_attributes(
        price: self.price,
        number_evidence: self.reference_number,
        account_id: self.accrued_credit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_credit_journal
    end

    def accrued_debit_journal
      return @accrued_debit_journal if @accrued_debit_journal.present?
      @accrued_debit_journal = Journal
        .where(
          journalable_id: self.id,
          journalable_type: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}]%"
        ).first
      if !@accrued_debit_journal.present?
        @accrued_debit_journal = Journal.new(
          journalable_id: self.id,
          journalable_type: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.id}]<br/>#{self.description}"
        )
      end

      @accrued_debit_journal.assign_attributes(
        price: self.price,
        number_evidence: self.reference_number,
        account_id: self.contract.accrued_debit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_debit_journal
    end
  end
end
