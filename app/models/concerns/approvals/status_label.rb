module Approvals
  module StatusLabel extend ActiveSupport::Concern
    def status_label
      if accepted?
        return 'success'
      end
      if waiting?
        return 'muted'
      end
      if rejected?
        return 'danger'
      end
    end
  end
end
