# frozen_string_literal: true

module Bas
  module Statuses extend ActiveSupport::Concern
    def refresh_status!
      refresh_status
      save! if changed?
    end

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
    end

    def status_html
      <<-EOS
        <span class='label label-light-#{status_label} label-pill label-inline mr-2'>
          #{status.present? ? I18n.t(status) : '-'}
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
