# frozen_string_literal: true

module Rates
  module RoundBuyingAndSellingAfterCreate extend ActiveSupport::Concern
    included do
      before_create :round_buying_and_selling_after_create
    end

    def round_buying_and_selling_after_create
      self.buying = self.buying.to_f.round
      self.selling = self.selling.to_f.round
    end
  end
end

