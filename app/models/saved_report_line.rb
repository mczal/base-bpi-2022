# == Schema Information
#
# Table name: saved_report_lines
#
#  id                 :uuid             not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  month              :integer
#  year               :integer
#  date               :date
#  report_line_id     :uuid
#  price_idr_cents    :decimal(, )      default(0.0), not null
#  price_idr_currency :string           default("IDR"), not null
#  price_usd_cents    :decimal(, )      default(0.0), not null
#  price_usd_currency :string           default("USD"), not null
#
class SavedReportLine < ApplicationRecord
  belongs_to :report_line

  monetize :price_idr_cents, with_currency: :idr
  monetize :price_usd_cents, with_currency: :usd

  validates :month, :year, :date,
    presence: true
end
