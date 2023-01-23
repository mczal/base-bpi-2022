# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :require_login

  layout 'homes'
  before_action :reports

  def reports
    @reports = Report.where(company: current_company)
  end

  def index
    # @dashboard_presenters = Dashboards::IndexPresenter.new(
      # params[:start_date], params[:end_date], current_company
    # )
    # return redirect_to admin_root_path(slug: current_company.slug)
  end

  def err_page
    sample_err_methods
  end

  def current_company
    @current_company ||= current_user.company
  end

  private
  def sample_err_methods
    raise "This is sample_err_methods"
  end
end
