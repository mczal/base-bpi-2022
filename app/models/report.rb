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
