class SavedReportLine < ApplicationRecord
  belongs_to :report_line

  monetize :price_idr_cents, with_currency: :idr
  monetize :price_usd_cents, with_currency: :usd

  validates :month, :year, :date,
    presence: true
end
