# frozen_string_literal: true

module Contracts
  module SynchronizeToEndedAtAfterSave extend ActiveSupport::Concern
    included do
      before_save :synchronize_to_ended_after_save
    end

    def synchronize_to_ended_after_save
      self.ended_at = self.started_at + self.time_period.days
    end
  end
end
