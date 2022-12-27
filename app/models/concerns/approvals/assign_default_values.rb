module Approvals
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
    end

    def assign_default_values
      if self.status.nil?
        self.status = :waiting
      end
    end
  end
end

