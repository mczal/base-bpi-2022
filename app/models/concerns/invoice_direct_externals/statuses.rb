# frozen_string_literal: true

module InvoiceDirectExternals
  module Statuses extend ActiveSupport::Concern
    # def refresh_status!
      # refresh_status
      # save! if changed?
    # end

    def status_label
      if !status.present?
        return 'dark'
      end
      if status == 'draft'
        return 'warning'
      end
      if status == 'ok'
        return 'primary'
      end
      if status == 'rejected'
        return 'dark'
      end
      if status == 'approved'
        return 'danger'
      end
      if status == 'paid'
        return 'success'
      end
    end

    def status_html
      if self.status.present?
        if self.draft?
          res = 'Draft'
        elsif self.ok?
          res = 'Menunggu Approval'
        elsif self.rejected?
          res = 'Approval Ditolak - Menunggu Perbaikan'
        elsif self.approved?
          res = 'Approved - Menunggu Pembayaran'
        elsif self.paid?
          res = 'Lunas'
        else
          res = I18n.t(self.status)
        end
      else
        res = '-'
      end

      <<-EOS
        <span class='label label-light-#{status_label} label-pill label-inline mr-2' style="height:auto;text-align:center;">
          #{res}
        </span>
      EOS
    end

    def status_docs
      <<-EOS
        <div class="text-#{invoices.present? ? 'success':'danger'}">
          Inv: #{invoices.present? ? 'OK':'NO'}
        </div>
      EOS
    end
  end
end
