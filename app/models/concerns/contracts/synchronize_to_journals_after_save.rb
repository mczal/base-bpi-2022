# frozen_string_literal: true

module Contracts
  module SynchronizeToJournalsAfterSave extend ActiveSupport::Concern
    included do
      # after_save :synchronize_to_journals_after_save
    end

    def synchronize_to_journals_after_save
      accrued_debit_journal.save! if accrued_debit_journal.new_record? || accrued_debit_journal.changed?
      accrued_credit_journal.save! if accrued_credit_journal.new_record? || accrued_credit_journal.changed?
    end

    def accrued_journals
      return @accrued_journals if @accrued_journals.present?

      ba_ids = self.bas.ids
      if !ba_ids.present?
        return @accrued_journals = Journal.where('1=2')
      end

      @accrued_journals = Journal
        .where('description ILIKE ?', "%[#{ba_ids[0]}]%")
      ba_ids.drop(1).each do |ba_id|
      @accrued_journals = @accrued_journals
        .or(
          Journal
            .where('description ILIKE ?', "%[#{ba_id}]%")
        )
      end

      @accrued_journals = @accrued_journals
        .reorder(created_at: :asc)
    end

    def accrued_credit_journal
      return @accrued_credit_journal if @accrued_credit_journal.present?
      @accrued_credit_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
        ).where(
          'description ILIKE ?', "%[#{self.id}]%"
        ).first
      if !@accrued_credit_journal.present?
        @accrued_credit_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :credit,
          description: "[ACCRUED_IT][#{self.id}]<br/>#{self.description}"
        )
      end

      @accrued_credit_journal.assign_attributes(
        price: self.price,
        number_evidence: self.ref_number,
        account_id: self.accrued_credit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_credit_journal
    end

    def accrued_debit_journal
      return @accrued_debit_journal if @accrued_debit_journal.present?
      @accrued_debit_journal = Journal
        .where(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
        ).where(
          'description ILIKE ?', "%[#{self.id}]%"
        ).first
      if !@accrued_debit_journal.present?
        @accrued_debit_journal = Journal.new(
          record_id: self.id,
          record_class: self.class.to_s,
          type_journal: :debit,
          description: "[ACCRUED_IT][#{self.id}]<br/>#{self.description}"
        )
      end

      @accrued_debit_journal.assign_attributes(
        price: self.price,
        number_evidence: self.ref_number,
        account_id: self.accrued_debit_id,
        date: self.created_at.localtime.to_date,
      )
      @accrued_debit_journal
    end
  end
end
