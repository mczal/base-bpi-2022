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
