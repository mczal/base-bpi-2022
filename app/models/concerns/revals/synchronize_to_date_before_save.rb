module Revals
  module SynchronizeToDateBeforeSave extend ActiveSupport::Concern
    included do
      before_save :synchronize_to_date_before_save
    end

    def synchronize_to_date_before_save
      self.date = Date.strptime(self.periode, '%m-%Y').end_of_month
    end
  end
end
