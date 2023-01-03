class ReportLine < ApplicationRecord
  include ReportLines::Styles
  include ReportLines::Prices
  include ReportLines::References

  belongs_to :report
  default_scope { order(order: :asc) }

  enum group: {
    title: 'title',
    value: 'value',
    accumulation: 'accumulation',
    break: 'break',
  }
end
