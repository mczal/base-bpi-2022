module Approvals
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
    end

    def assign_default_values
      if self.status.nil?
        self.status = :waiting
      end
      if self.number_of_notification_sent.nil?
        self.number_of_notification_sent = 0
      end
    end
  end
end

