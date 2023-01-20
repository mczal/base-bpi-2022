module GeneralTransactions
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
    end

    def assign_default_values
      if self.end_of_period_rates_options.nil?
        self.end_of_period_rates_options = {}
      end
      if self.fixed_rates_options.nil?
        self.fixed_rates_options = {}
      end
      if !self.status.present?
        self.status = :waiting_for_approval
      end
      if !self.source.present?
        self.source = :original
      end
    end
  end
end
