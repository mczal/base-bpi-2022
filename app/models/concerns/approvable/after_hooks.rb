# frozen_string_literal: true

module Approvable
  module AfterHooks extend ActiveSupport::Concern
    included do
      after_create :generate_approvals
    end

    def generate_approvals
      return if self.accepted?

      approval_lines.each.with_index(1) do |approval, i|
        approval = Approval.find_or_initialize_by(
          approvable: self,
          name: approval[:name],
          role: approval[:role],
          order: i
        )

        # if (self.class.name == 'GeneralTransaction') && (self.calculator?)
        # if (self.class.name == 'GeneralTransaction')
          # approval.assign_attributes(
            # status: 'accepted'
          # )
        # end

        approval.save!
      end
    end
  end
end
