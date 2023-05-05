# frozen_string_literal: true

module Revals
  module ValidateSinglePeriods extend ActiveSupport::Concern
    included do
      validate :validate_single_period
    end

    def validate_single_period
      return unless self.new_record?

      date_from_period = Date.strptime(self.period, '%m-%Y').end_of_month
      if ::Reval.find_by(date: date_from_period).present?
        self.errors.add :period, "> Tidak bisa menambahkan data Reval dengan periode yang sudah ada."
        return false
      end

      true
    end
  end
end
