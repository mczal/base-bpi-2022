class Client < ApplicationRecord
  include PgSearch::Model
  include Clients::FormattedNpwp
  extend Clients::Pln

  belongs_to :company
  belongs_to :bank, optional: true

  enum group: {
    customer: 'customer',
    vendor: 'vendor',
    other: 'other'
  }

  enum pkp_group: {
    pkp: 'pkp',
    non_pkp: 'non_pkp'
  }

  pg_search_scope :search,
    against: %i[name phone_number email npwp],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }
end
