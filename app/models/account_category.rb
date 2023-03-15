# == Schema Information
#
# Table name: account_categories
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  code            :string
#  description     :string
#  bottom_treshold :integer
#  upper_treshold  :integer
#
class AccountCategory < ApplicationRecord
  include PgSearch::Model
  include AccountCategories::AssignDefaultValues

  has_many :accounts

  pg_search_scope :search,
    against: %i[code description],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def readable_name
    "#{code} | #{description}"
  end
end
