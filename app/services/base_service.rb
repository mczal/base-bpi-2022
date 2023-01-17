# frozen_string_literal: true

class BaseService
  def error_messages
    @error_messages ||= []
  end

  def full_error_messages
    @full_messages ||= error_messages.join('\n')
  end

  def full_error_messages_html
    @full_messages ||= error_messages.join('<br/>')
  end

  def run
    validate_before_action
    return false if error_messages.present?

    ActiveRecord::Base.transaction do
      action
    end

    return false if error_messages.present?

    true
  # rescue StandardError => e
    # Rails.logger.error "[SERVICE][ERROR] #{e}"
    # error_messages << e.message
    # false
  end

  def validate_before_action; end
end
