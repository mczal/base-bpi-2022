# == Schema Information
#
# Table name: accounts
#
#  id                  :uuid             not null, primary key
#  code                :string
#  name                :string
#  company_id          :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  balance_type        :string
#  account_category_id :uuid
#  isak_16             :boolean          default(FALSE)
#  non_isak            :boolean          default(FALSE)
#  fiskal              :boolean          default(FALSE)
#
class Account < ApplicationRecord
  include PgSearch::Model
  include Accounts::AssignDefaultValues
  include Accounts::MasterBusinessUnits
  include Accounts::ReportCategoryForCheckbox
  include Accounts::Reports::Balances

  belongs_to :company
  belongs_to :account_category

  has_many :account_master_business_units
  has_many :master_business_units, through: :account_master_business_units

  enum balance_type: {
    debit: 'debit',
    kredit: 'kredit',
  }

  pg_search_scope :search,
    against: %i[code name],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def journals
    @journals ||= Journal.where(code: self.code)
  end

  def general_transaction_lines
    @general_transaction_lines ||= GeneralTransactionLine.where(code: self.code)
  end

  def readable_name
    @readable_name ||= "#{code}  |  #{name}"
  end
end
