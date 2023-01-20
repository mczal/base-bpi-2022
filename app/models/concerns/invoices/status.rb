# frozen_string_literal: true

module Invoices
  module Status
    extend ActiveSupport::Concern
    def status
      return 'paid' if paid_at.present?

      'pending'
    end

    def status_label
      return 'success' if status == 'paid'

      'danger' if status == 'pending'
    end

    def status_html
      <<-EOS
        <span class='label label-light-#{status_label} label-pill label-inline mr-2'>
          #{status.present? ? I18n.t(status).titlecase : '-'}
        </span>
      EOS
    end

    def paid?
      status == 'paid'
    end
  end
end
