module Revals
  module Periods extend ActiveSupport::Concern
    include DateHelper
    def readable_period
      @readable_period ||= readable_date_5(Date.strptime(self.period, '%m-%Y'))
    end
  end
end
