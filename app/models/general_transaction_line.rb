# == Schema Information
#
# Table name: general_transaction_lines
#
#  id                               :uuid             not null, primary key
#  code                             :string
#  description                      :string
#  general_transaction_id           :uuid             not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  price_idr_cents                  :decimal(, )      default(0.0), not null
#  price_idr_currency               :string           default("IDR"), not null
#  price_usd_cents                  :decimal(, )      default(0.0), not null
#  price_usd_currency               :string           default("USD"), not null
#  group                            :string
#  is_master_business_units_enabled :boolean          default(FALSE)
#  master_business_unit_id          :uuid
#  master_business_unit_location_id :uuid
#  master_business_unit_area_id     :uuid
#  master_business_unit_activity_id :uuid
#  rate_cents                       :decimal(, )      default(0.0), not null
#  rate_currency                    :string           default("IDR"), not null
#
class GeneralTransactionLine < ApplicationRecord
  include GeneralTransactionLines::AssignDefaultValues
  include GeneralTransactionLines::MasterBusinessUnits
  include GeneralTransactionLines::Price
  include GeneralTransactionLines::Accounts
  include GeneralTransactionLines::SetupJournals

  belongs_to :general_transaction

  belongs_to :master_business_unit, optional: true
  belongs_to :master_business_unit_location,
    foreign_key: 'master_business_unit_location_id',
    class_name: 'MasterBusinessUnit',
    optional: true
  belongs_to :master_business_unit_area,
    foreign_key: 'master_business_unit_area_id',
    class_name: 'MasterBusinessUnit',
    optional: true
  belongs_to :master_business_unit_activity,
    foreign_key: 'master_business_unit_activity_id',
    class_name: 'MasterBusinessUnit',
    optional: true

  has_many :journals, as: :journalable, dependent: :destroy

  monetize :price_idr_cents, with_currency: :idr
  monetize :price_usd_cents, with_currency: :usd
  monetize :rate_cents, with_currency: :idr

  enum group: {
    debit: 'debit',
    credit: 'credit',
  }
end
