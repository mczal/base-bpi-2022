# == Schema Information
#
# Table name: report_references
#
#  id             :uuid             not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  report_id      :uuid
#  account_code   :string
#  account_name   :string
#  reference_code :string
#
class ReportReference < ApplicationRecord
  belongs_to :report
end
