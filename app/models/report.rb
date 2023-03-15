# == Schema Information
#
# Table name: reports
#
#  id         :uuid             not null, primary key
#  name       :string
#  order      :integer
#  shown      :boolean
#  company_id :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group      :string
#
class Report < ApplicationRecord
  belongs_to :company

  has_many :report_lines, dependent: :destroy
  has_many :report_references, dependent: :destroy

  enum group: {
    cash_flow: 'cash_flow',
    income_statement: 'income_statement',
    balance_sheet: 'balance_sheet',
    other: 'other',
  }
end
