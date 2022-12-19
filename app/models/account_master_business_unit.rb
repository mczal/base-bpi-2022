class AccountMasterBusinessUnit < ApplicationRecord
  belongs_to :master_business_unit
  belongs_to :account
end
