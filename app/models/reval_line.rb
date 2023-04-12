class RevalLine < ApplicationRecord
  audited

  belongs_to :reval
  has_many :journals, as: :journalable, dependent: :destroy

  monetize :price_idr_cents, with_currency: :idr
  monetize :price_usd_cents, with_currency: :usd

  enum group: {
    debit: 'debit',
    credit: 'credit',
  }
end
