module Approvals
  module Siblings extend ActiveSupport::Concern
    def next
      self.approvable
        .approvals
        .where('approvals.order > ?', self.order)
        .limit(1)
        .first
    end

    def previous
      self.approvable
        .approvals
        .where('approvals.order < ?', self.order)
        .reorder(order: :desc)
        .limit(1)
        .first
    end
  end
end

