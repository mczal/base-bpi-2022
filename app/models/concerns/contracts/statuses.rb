# frozen_string_literal: true

module Contracts
  module Statuses extend ActiveSupport::Concern
    def refresh_status!
      refresh_status
      save! if changed?
    end

    def refresh_status
      return nil if price.to_money == 0
      now = DateTime.now
      if now < started_at && (!invoices.present? || !invoices.map{|x|x.status}.include?('paid'))
        self.status = :waiting
        return
      end

      total_invoices_price = invoices.sum{|x|x.price.to_money}.to_money
      if total_invoices_price == self.price
        self.status = :finished
        return
      end

      if (now >= started_at && now < ended_at) || (invoices.present? && invoices.map{|x|x.status}.include?('paid'))
        self.status = :ongoing
        return
      end

      if now >= ended_at && total_invoices_price < self.price
        self.status = :overdue
        return
      end
    end

    def status_label
      if !status.present?
        return 'dark'
      end
      if status == 'waiting'
        return 'warning'
      end
      if status == 'ongoing'
        return 'primary'
      end
      if status == 'finished'
        return 'success'
      end
      if status == 'overdue'
        return 'danger'
      end
    end

    def status_html
      <<-EOS
        <span class='label label-light-#{status_label} label-pill label-inline mr-2'>
          #{status.present? ? I18n.t(status) : '-'}
        </span>
      EOS
    end

    def status_description_html
      # <<-EOS
        # <div style="font-size:11px;">
          # <div>
            # #{paid_invoices.count} invoice dibayar
          # </div>
          # <div>
            # #{unpaid_invoices.count} invoice belum dibayar
          # </div>
        # </div>
      # EOS
    end

    def status_docs
      <<-EOS
        <div class="text-#{bas.present? ? 'success':'danger'}">
          BA: #{bas.present? ? 'OK':'NO'}
        </div>
      EOS
    end
  end
end
