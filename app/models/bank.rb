class Bank < ApplicationRecord
  audited
  include PgSearch::Model

  pg_search_scope :search,
    against: %i[code name],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def code_name
    "#{self.code} - #{self.name}"
  end
end
