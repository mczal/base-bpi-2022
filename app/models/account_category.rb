class AccountCategory < ApplicationRecord
  include PgSearch::Model
  include AccountCategories::AssignDefaultValues

  has_many :accounts

  pg_search_scope :search,
    against: %i[code description],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }
end
