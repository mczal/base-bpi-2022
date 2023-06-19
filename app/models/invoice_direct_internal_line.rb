# frozen_string_literal: true

class InvoiceDirectInternalLine < ApplicationRecord
  # include ::InvoiceDirectInternalLines::SynchronizeToGeneralTransactionsAfterSaveForPaid
  include ::GeneralTransactionLines::MasterBusinessUnits

  belongs_to :invoice_direct_internal
  belongs_to :cost_center, class_name: "Account"
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

  monetize :price_cents

  def code
    @code ||= cost_center.code
  end
end
