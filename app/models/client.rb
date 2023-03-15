# == Schema Information
#
# Table name: clients
#
#  id             :uuid             not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :string
#  email          :string
#  phone_number   :string
#  address        :text
#  npwp           :string
#  account_bank   :string
#  account_number :string
#  account_name   :string
#  group          :string
#  pkp_group      :string
#  bank_id        :uuid
#  company_id     :uuid
#
class Client < ApplicationRecord
  include PgSearch::Model
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
