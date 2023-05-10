class Journal < ApplicationRecord
  include PgSearch::Model
  include Journals::Helpers
  include Journals::AssignDefaultValues

  belongs_to :company
  belongs_to :journalable, polymorphic: true

  monetize :debit_idr_cents, with_currency: :idr
  monetize :credit_idr_cents, with_currency: :idr
  monetize :debit_usd_cents, with_currency: :usd
  monetize :credit_usd_cents, with_currency: :usd

  default_scope { order(date: :desc, number_evidence: :desc, created_at: :desc) }

  enum location: {
    site: 'site',
    jakarta: 'jakarta',
  }

  pg_search_scope :search,
    against: %i[number_evidence code description],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def rate_instance
    @rate_instance ||= Rate.find_by(id: self.rates_options['id'])
  end
  def rate_money
    @rate_money ||= self.rates_options['price'].to_money
  end

  def account
    @account ||= Account.find_by(code: self.code)
  end

  def source_path
    if self.journalable_type == 'GeneralTransactionLine'
      source_id = journalable.general_transaction_id
      return Rails.application.routes.url_helpers.admin_general_transaction_path(
        slug: company.slug, id: source_id
      )
    end
    if self.journalable_type == 'RevalLine'
      source_id = journalable.reval_id
      return Rails.application.routes.url_helpers.admin_reval_path(
        slug: company.slug, id: source_id
      )
    end
  end
end
