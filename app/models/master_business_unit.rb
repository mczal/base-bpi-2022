# == Schema Information
#
# Table name: master_business_units
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  code        :string
#  description :text
#  group       :string
#
class MasterBusinessUnit < ApplicationRecord
  include PgSearch::Model

  has_many :account_master_business_units
  has_many :accounts, through: :account_master_business_units

  enum group: {
    business_unit: 'business_unit',
    business_unit_location: 'business_unit_location',
    business_unit_area: 'business_unit_area',
    business_unit_activity: 'business_unit_activity'
  }

  pg_search_scope :search,
    against: %i[code description group],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def readable_name
    "#{code} - #{description}"
  end
end
