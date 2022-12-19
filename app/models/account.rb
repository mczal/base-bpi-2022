class Account < ApplicationRecord
  include PgSearch::Model
  include Accounts::AssignDefaultValues
  include Accounts::MasterBusinessUnits
  include Accounts::ReportCategoryForCheckbox

  belongs_to :company
  belongs_to :account_category

  has_many :account_master_business_units
  has_many :master_business_units, through: :account_master_business_units

  enum balance_type: {
    debit: 'debit',
    kredit: 'kredit',
  }

  pg_search_scope :search,
    against: %i[code name],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }
end
