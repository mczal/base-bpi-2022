# frozen_string_literal: true

module GeneralTransactionLines
  module SetupJournals extend ActiveSupport::Concern
    included do
      after_create :setup_journals
    end

    def setup_journals
      return unless self.general_transaction.accepted?

      journal = Journal.find_or_initialize_by(
        journalable_type: self.class.to_s,
        journalable_id: self.id,
      )
      journal.assign_attributes(
        date: self.general_transaction.date,
        code: self.code,
        number_evidence: self.general_transaction.number_evidence,
        location: self.general_transaction.location,
        company_id: self.general_transaction.company_id,
        description: self.description,
        recipient: self.recipient,
        debit_idr: (self.debit? ? self.idr : 0),
        credit_idr: (self.credit? ? self.idr : 0),
        debit_usd: (self.debit? ? self.usd : 0),
        credit_usd: (self.credit? ? self.usd : 0),
        rates_options: {
          id: self.general_transaction.fixed_rates_options['id'],
          price: self.rate.amount
        },
      )
      if self.is_master_business_units_enabled?
        journal.master_business_unit = self.master_business_units_string
      end
      journal.save! if journal.new_record? || journal.changed?
    end
  end
end
