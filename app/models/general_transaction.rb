class GeneralTransaction < ApplicationRecord
  audited
  include PgSearch::Model
  include Approvable::AfterHooks
  include GeneralTransactions::Approvals
  include GeneralTransactions::AssignDefaultValues
  include GeneralTransactions::Price
  include GeneralTransactions::Statuses
  extend GeneralTransactions::NumberEvidenceRetrievers

  belongs_to :company
  belongs_to :transactionable, polymorphic: true, optional: true
  has_many :general_transaction_lines, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy
  has_many_attached :files

  validate :closed_book

  enum rates_source: {
    bank_of_indonesia: 'bank_of_indonesia',
    ministry_of_finance: 'ministry_of_finance'
  }
  enum rates_group: {
    fixed_rates: 'fixed_rates',
    end_of_period_rates: 'end_of_period_rates'
  }
  enum input_option: {
    idr: 'idr',
    usd: 'usd'
  }
  enum status: {
    waiting_for_approval: 'waiting_for_approval',
    accepted: 'accepted',
    rejected: 'rejected',
  }
  enum location: {
    site: 'site',
    jakarta: 'jakarta',
  }
  enum source: {
    import: 'import',
    original: 'original',
    ba: 'ba',
    invoice: 'invoice'
  }

  accepts_nested_attributes_for :general_transaction_lines

  pg_search_scope :search,
    against: %i[number_evidence],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def closed_book
    closed_journals = ClosedJournal.where("date >= ?", self.date)
    if closed_journals.present?
      self.errors.add :base, "Jurnal sudah ditutup"
      return false
    end

    return true
  end

  def rate_instance
    @rate_instance ||= Rate.find_by(id: self.fixed_rates_options['id'])
  end
  def rate_money
    @rate_money ||= rate_instance&.middle.to_money
  end
  def journals
    @journals ||= Journal.where(
      journalable_type: 'GeneralTransactionLine',
      journalable_id: general_transaction_lines.ids
    )
  end
end
