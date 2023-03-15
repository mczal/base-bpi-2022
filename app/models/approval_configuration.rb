# == Schema Information
#
# Table name: approval_configurations
#
#  id                       :uuid             not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  roles                    :string           default([]), is an Array
#  bottom_treshold_cents    :decimal(, )      default(0.0), not null
#  bottom_treshold_currency :string           default("IDR"), not null
#  upper_treshold_cents     :decimal(, )      default(0.0), not null
#  upper_treshold_currency  :string           default("IDR"), not null
#
class ApprovalConfiguration < ApplicationRecord
  audited
  include Audited::Logs

  monetize :bottom_treshold_cents, with_currency: :idr
  monetize :upper_treshold_cents, with_currency: :idr

  default_scope { order(bottom_treshold_cents: :asc) }

  def readable_rule
    if bottom_treshold == 0 && upper_treshold == 0
      return ''
    end
    if bottom_treshold > 0 && upper_treshold > 0
      return "#{bottom_treshold.format} <b><</b> X <b><=</b> #{upper_treshold.format}".html_safe
    end
    if bottom_treshold > 0
      return "#{bottom_treshold.format} <b><</b> X".html_safe
    end
    return 'UNDEFINED RULE'
  end
end
