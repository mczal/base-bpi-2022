module Approvals
  module NotificationText extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers

    def notification_icon_html
      if self.accepted?
        return <<-EOS.strip.html_safe
          <i class="flaticon2-correct text-success"></i>
        EOS
      elsif self.waiting?
        return <<-EOS.strip.html_safe
          <i class="flaticon2-writing text-warning"></i>
        EOS
      elsif self.rejected?
        return <<-EOS.strip.html_safe
          <i class="flaticon2-exclamation text-danger"></i>
        EOS
      else
        return <<-EOS.strip.html_safe
          <i class="flaticon2-quotation-mark text-dark"></i>
        EOS
      end
    end

    def notification_text
      if self.accepted?
        return "Transaksi Sudah di Approved"
      elsif self.waiting?
        return "Transaksi Menunggu Persetujuan Anda (#{self.role.titlecase})"
      elsif self.rejected?
        return "Transaksi Ditolak! (#{self.role.titlecase})"
      else
        return "N/A"
      end
    end

    def notification_link
      if self.approvable_type == 'GeneralTransaction'
        return admin_general_transaction_path(id: self.approvable_id, slug: Company.bpi.slug)
      elsif self.approvable_type == 'Reval'
        return admin_reval_path(id: self.approvable_id, slug: Company.bpi.slug)
      elsif self.approvable_type == 'AuditAdjustment'
        return admin_audit_adjustment_path(id: self.approvable_id, slug: Company.bpi.slug)
      else
        '#'
      end
    end
  end
end
