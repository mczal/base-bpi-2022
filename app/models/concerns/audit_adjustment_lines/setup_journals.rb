# frozen_string_literal: true

module AuditAdjustmentLines
  module SetupJournals extend ActiveSupport::Concern
    included do
      after_create :setup_journals
    end

    def setup_journals
      return unless self.audit_adjustment.accepted?

      journal = Journal.find_or_initialize_by(
        journalable_type: self.class.to_s,
        journalable_id: self.id,
      )
      journal.assign_attributes(
        date: self.audit_adjustment.date,
        code: self.account.code,
        number_evidence: self.audit_adjustment.number_evidence,
        location: 'jakarta',
        company_id: Company.bpi.id,
        description: self.description,
        debit_idr: (self.debit? ? self.price_idr : 0),
        credit_idr: (self.credit? ? self.price_idr : 0),
        debit_usd: (self.debit? ? self.price_usd : 0),
        credit_usd: (self.credit? ? self.price_usd : 0),
        rates_options: {
          id: nil,
          price: self.rate.amount
        },
      )
      journal.save! if journal.new_record? || journal.changed?
    end
  end
end
