module Admin
  class MasterBusinessUnitsController < ::AdminController
    before_action :master_business_unit, only: %i[edit]

    def index
      @master_business_unit = MasterBusinessUnit.new
    end

    def create
      service = ::MasterBusinessUnits::CreateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_master_business_units_path(slug: params[:slug])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_master_business_units_path(slug: params[:slug])
    end

    def edit
      render partial: 'form'
    end

    def update
      service = ::MasterBusinessUnits::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_master_business_units_path(slug: params[:slug])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_master_business_units_path(slug: params[:slug])
    end

    def destroy
      ActiveRecord::Base.transaction do
        master_business_unit.destroy!
        flash[:success] = "Berhasil!"
        redirect_to admin_master_business_units_path(slug: params[:slug])
      end
    end

    private
      def master_business_unit
        @master_business_unit = MasterBusinessUnit.find_by(id: params[:id])
      end
  end
end
