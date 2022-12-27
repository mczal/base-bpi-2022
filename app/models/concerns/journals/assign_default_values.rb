module Journals
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
    end

    def assign_default_values
      if self.rates_options.nil?
        self.rates_options = {}
      end
    end
  end
end

