# == Schema Information
#
# Table name: account_master_business_units
#
#  id                      :uuid             not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  account_id              :uuid
#  master_business_unit_id :uuid
#
class AccountMasterBusinessUnit < ApplicationRecord
  belongs_to :master_business_unit
  belongs_to :account
end
