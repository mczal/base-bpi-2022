module Approvals
  module RedirectHandlers extend ActiveSupport::Concern
    def redirect_approvals_after_update
      if !request.referrer.to_s.match(/approval/)
        return redirect_back fallback_location: root_path
      end

      next_sibl = approval.next
      if next_sibl.present? && current_user.roles_name.include?(next_sibl.role)
        return redirect_to admin_approval_path(id: next_sibl.id, slug: current_company.slug)
      end
      return redirect_to admin_approvals_path
    end
  end
end
