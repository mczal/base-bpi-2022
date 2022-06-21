# frozen_string_literal: true

class AdminController < ActionController::Base
  include Clearance::Controller
  before_action :require_login

  def current_company 
    @current_company ||= current_user.company
  end

  def append_info_to_payload(payload)
    super
    case
    when payload[:status] == 200
      payload[:level] = "INFO"
    when payload[:status] == 302
      payload[:level] = "WARN"
    else
      payload[:level] = "ERROR"
    end
  end
end