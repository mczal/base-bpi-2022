# == Schema Information
#
# Table name: report_lines
#
#  id         :uuid             not null, primary key
#  name       :string
#  order      :integer
#  codes      :string           default([]), is an Array
#  formula    :string
#  group      :string
#  report_id  :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
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
