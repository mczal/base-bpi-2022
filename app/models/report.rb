class Report < ApplicationRecord
  belongs_to :company

  has_many :report_lines, dependent: :destroy
  has_many :report_references, dependent: :destroy
end
