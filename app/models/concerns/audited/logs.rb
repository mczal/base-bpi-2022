module Audited
  module Logs extend ActiveSupport::Concern
    def last_log
      @last_log ||= self.audits
        .limit(1)
        .reorder(version: :desc)
        .first
    end

    def first_log
      @first_log ||= self.audits
        .limit(1)
        .reorder(version: :asc)
        .first
    end
  end
end

