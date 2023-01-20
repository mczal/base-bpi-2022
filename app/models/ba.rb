class Ba < ApplicationRecord
  include Bas::Statuses
  # include Bas::SynchronizeToJournalsAfterSave
  include Bas::SynchronizeToGeneralTransactionsAfterSave

  has_one_attached :file
  has_many_attached :other_files

  belongs_to :contract
  belongs_to :accrued_credit, class_name: 'Account'

  has_many :invoices, as: :invoiceable
  has_many :general_transactions, as: :transactionable

  monetize :price_cents

  enum status: {
    draft: 'draft',
    ok: 'ok'
  }

  def number_of_days_late
    self._number_of_days_late
  end
  def number_of_days_late= x
    self._number_of_days_late = x
  end

  def name_for_select
    "#{reference_number} | #{contract.client.name}"
  end
end
