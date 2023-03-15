# == Schema Information
#
# Table name: account_beginning_balances
#
#  id                 :uuid             not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  code               :string
#  price_idr_cents    :decimal(, )      default(0.0), not null
#  price_idr_currency :string           default("IDR"), not null
#  price_usd_cents    :decimal(, )      default(0.0), not null
#  price_usd_currency :string           default("USD"), not null
#  year               :integer
#
class AccountBeginningBalance < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search,
    against: %i[code],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  monetize :price_idr_cents, with_currency: :idr
  monetize :price_usd_cents, with_currency: :usd

  default_scope { order(year: :asc) }

  def account
    @account ||= Account.find_by(code: self.code)
  end

  def debit_idr
    return @debit_idr if @debit_idr.present?
    return @debit_idr = 0.to_money if price_idr < 0
    @debit_idr = price_idr
  end
  def credit_idr
    return @credit_idr if @credit_idr.present?
    return @credit_idr = 0.to_money if price_idr >= 0
    @credit_idr = price_idr.abs
  end
  def debit_usd
    return @debit_usd if @debit_usd.present?
    return @debit_usd = 0.to_money.with_currency(:usd) if price_usd < 0
    @debit_usd = price_usd
  end
  def credit_usd
    return @credit_usd if @credit_usd.present?
    return @credit_usd = 0.to_money.with_currency(:usd) if price_usd >= 0
    @credit_usd = price_usd.abs
  end
end
