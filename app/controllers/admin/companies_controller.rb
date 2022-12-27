class Admin::CompaniesController < AdminController
  before_action :company, only: [:show, :update, :edit, :destroy]

  def index
    @company = Company.new
  end

  def edit
    @company = Company.find_by(id: params[:id])
  end

  def update
    @company_service = Companies::UpdateService.new(params)
    if @company_service.run
      return redirect_to admin_companies_path(slug: current_company.slug), notice: "Perusahaan berhasil di buat"
    end

    redirect_to admin_companies_path(slug: current_company.slug), alert: @company_service.full_error_messages
  end

  def create
    @company_service = Companies::CreateService.new(params)
    if @company_service.run
      return redirect_to admin_companies_path(slug: current_company.slug), notice: "Perusahaan berhasil di buat"
    end

    redirect_to admin_companies_path(slug: current_company.slug), alert: @company_service.full_error_messages
  end

  def destroy
    if @company.destroy
      return redirect_to admin_companies_path(slug: current_company.slug), notice: "Perusahaan berhasil di hapus"
    end

    redirect_to admin_companies_path(slug: current_company.slug), alert: @company.errors.full_error_messages
  end

  private
  def company
    @company = Company.find_by(id: params[:id])
    return redirect_to admin_companies_path(slug: current_company.slug), alert: "Perusahaan tidak ditemukan" if @company.blank?
  end
end
