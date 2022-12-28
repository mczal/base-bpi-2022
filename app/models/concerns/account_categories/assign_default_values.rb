module AccountCategories
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      # before_create :assign_default_value
      before_save :reapply_treshold_and_code_range
    end

    # def assign_default_value
      # if !self.code.present?
        # self.code = "#{self.bottom_treshold} - #{self.upper_treshold}"
      # end
    # end

    def reapply_treshold_and_code_range
      self.code = "#{self.bottom_treshold} - #{self.upper_treshold}"
    end
  end
end
