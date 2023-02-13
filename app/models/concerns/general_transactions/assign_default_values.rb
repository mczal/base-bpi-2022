module GeneralTransactions
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
      before_update :reassign_rate_to_line_if_source_calculator
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

    def reassign_rate_to_line_if_source_calculator
      return unless self.calculator?
      general_transaction_lines.each do |line|
        line.reassign_rate_if_source_calculator
        line.save!
      end
    end
  end
end
