# frozen_string_literal: true

module GeneralTransactionLines
  module SetupJournals extend ActiveSupport::Concern
    def setup_journals
      journal = Journal.find_or_initialize_by(
        journalable_type: self.class.to_s,
        journalable_id: self.id,
      )
      journal.assign_attributes(
        date: self.general_transaction.date,
        code: self.code,
        number_evidence: self.general_transaction.number_evidence,
        company_id: self.general_transaction.company_id,
        description: self.description,
        debit_idr: (self.debit? ? self.idr : 0),
        credit_idr: (self.credit? ? self.idr : 0),
        debit_usd: (self.debit? ? self.usd : 0),
        credit_usd: (self.credit? ? self.usd : 0),
        rates_options: self.general_transaction.fixed_rates_options,
      )
      journal.save! if journal.new_record? || journal.changed?
    end
  end
end
