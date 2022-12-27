class AccountBeginningBalance < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search,
    against: %i[code],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  monetize :price_idr_cents, with_currency: :idr
  monetize :price_usd_cents, with_currency: :usd

  def account
    @account ||= Account.find_by(code: self.code)
  end
end
