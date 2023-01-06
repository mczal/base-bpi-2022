module Admin
  module Settings
    class RatesController < ::AdminController
      before_action :rate, only: %i[edit]

      def index
        @rate = Rate.new
      end

      def create
        service = ::Rates::CreateService.new(params)
        if !service.run
          flash[:danger] = "Gagal. #{service.full_error_messages_html}"
          return redirect_to admin_settings_rates_path(slug: params[:slug])
        end

        flash[:success] = "Berhasil!"
        redirect_to admin_settings_rates_path(slug: params[:slug])
      end

      def edit
        render partial: 'form'
      end

      # def update
        # service = ::Rates::UpdateService.new(params)
        # if !service.run
          # flash[:danger] = "Gagal. #{service.full_error_messages_html}"
          # return redirect_to admin_settings_rates_path(slug: params[:slug])
        # end

        # flash[:success] = "Berhasil!"
        # redirect_to admin_settings_rates_path(slug: params[:slug])
      # end

      def destroy
        ActiveRecord::Base.transaction do
          rate.destroy!
          flash[:success] = "Berhasil!"
          redirect_to admin_settings_rates_path(slug: params[:slug])
        end
      end

      private
        def rate
          @rate = Rate.find_by(id: params[:id])
        end
    end
  end
end
