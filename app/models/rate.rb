class Rate < ApplicationRecord
  audited
  include Rates::RoundBuyingAndSellingAfterCreate
  include DateHelper
  extend Rates::Periods

  monetize :buying_cents
  monetize :selling_cents

  enum origin: {
    bank_of_indonesia: 'bank_of_indonesia',
    ministry_of_finance: 'ministry_of_finance'
  }

  default_scope { order(created_at: :desc) }

  def middle
    @middle ||= ((buying + selling) / 2.0).round
  end

  def readable_name
    @readable_name ||= "#{self.origin.titlecase} - #{readable_date_3 self.published_date} | #{middle.format}"
  end
end
