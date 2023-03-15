# == Schema Information
#
# Table name: closed_journals
#
#  id         :uuid             not null, primary key
#  name       :string
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ClosedJournal < ApplicationRecord
  audited
end
