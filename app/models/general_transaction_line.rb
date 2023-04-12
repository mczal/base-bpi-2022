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
