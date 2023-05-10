class AuditAdjustmentLine < ApplicationRecord
  audited
  include AuditAdjustmentLines::SetupJournals

  belongs_to :audit_adjustment
  belongs_to :account
  has_many :journals, as: :journalable, dependent: :destroy

  monetize :price_idr_cents, with_currency: :idr
  monetize :price_usd_cents, with_currency: :usd
  monetize :rate_cents, with_currency: :idr

  enum group: {
    debit: 'debit',
    credit: 'credit',
  }
end
