module GeneralTransactionLines
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
    end

    def assign_default_values
      if self.is_master_business_units_enabled.nil?
        self.is_master_business_units_enabled = false
      end
    end
  end
end
