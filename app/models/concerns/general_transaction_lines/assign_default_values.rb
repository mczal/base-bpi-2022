module GeneralTransactionLines
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
      before_save :reassign_rate_if_source_calculator
      before_save :reassign_rate_if_changes
    end

    def assign_default_values
      if self.is_master_business_units_enabled.nil?
        self.is_master_business_units_enabled = false
      end
      # if self.rate == 0
        # self.rate = self.general_transaction.rate_money
      # end
    end

    def reassign_rate_if_source_calculator
      return unless self.general_transaction.calculator?
      self.rate = self.general_transaction.rate_money
    end

    def reassign_rate_if_changes
      return if self.general_transaction.calculator?
      return if self.general_transaction.custom?
      if self.rate == 0
        self.rate = self.general_transaction.rate_money
      end
      if self.general_transaction.bank_of_indonesia? || self.general_transaction.ministry_of_finance?
        self.rate = self.general_transaction.rate_money
      end
    end
  end
end
