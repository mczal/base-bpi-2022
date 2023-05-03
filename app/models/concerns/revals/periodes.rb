module Revals
  module Periodes extend ActiveSupport::Concern
    include DateHelper
    def readable_periode
      @readable_periode ||= readable_date_5(Date.strptime(self.periode, '%m-%Y'))
    end
  end
end
