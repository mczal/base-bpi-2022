class ReportLine < ApplicationRecord
  include ReportLines::Styles
  include ReportLines::Prices
  include ReportLines::References

  belongs_to :report
  has_many :saved_report_lines, dependent: :destroy

  default_scope { order(order: :asc) }

  enum group: {
    title: 'title',
    value: 'value',
    accumulation: 'accumulation',
    break: 'break',
  }
end
