module Accounts
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_value
    end

    def assign_default_value
      if self.isak_16.nil?
        self.isak_16 = false
      end
      if self.non_isak.nil?
        self.non_isak = false
      end
      if self.fiskal.nil?
        self.fiskal = false
      end
    end
  end
end
