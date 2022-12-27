# frozen_string_literal: true

module GeneralTransactions
  module Statuses extend ActiveSupport::Concern
    def status_for_html
      <<-EOS.html_safe
        <span
          class="text-#{status_label_html_class} font-size-sm font-weight-bold text-hover-primary"
          style="width:inherit;"
        >
          #{status_icon_html}
          #{I18n.t(self.status).titlecase}
        </span>
      EOS
    end

    def status_icon_html
      return @status_icon_html if @status_icon_html.present?

      if waiting_for_approval?
        return @status_icon_html = "<i class='far fa-question-circle text-#{status_label_html_class}'></i>"
      elsif accepted?
        return @status_icon_html = "<i class='far fa-check-circle text-#{status_label_html_class}'></i>"
      elsif rejected?
        return @status_icon_html = "<i class='far fa-times-circle text-#{status_label_html_class}'></i>"
      else
        return @status_icon_html = ""
      end
    end

    def status_label_html_class
      return @status_label_html_class if @status_label_html_class.present?

      if waiting_for_approval?
        return @status_label_html_class = 'warning'
      elsif accepted?
        return @status_label_html_class = 'success'
      elsif rejected?
        return @status_label_html_class = 'danger'
      else
        return @status_label_html_class = 'dark'
      end
    end
  end
end
