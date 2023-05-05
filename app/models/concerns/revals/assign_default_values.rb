module Revals
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
      before_save :synchronize_to_date_before_save
    end

    def assign_default_values
      if !self.status.present?
        self.status = :waiting_for_approval
      end
      if !self.number_evidence.present?
        self.number_evidence = ::Reval.retrieve_new_number_evidence 'jakarta', :bj
      end
    end

    def synchronize_to_date_before_save
      self.date = Date.strptime(self.period, '%m-%Y').end_of_month
    end
  end
end
