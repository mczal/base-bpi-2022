# frozen_string_literal: true

module Admin
  class ClientsController < ::AdminController
    before_action :client, only: %i[edit]

    def index
      @client = Client.new
    end

    def create
      service = ::Clients::CreateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_clients_path(slug: params[:slug])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_clients_path(slug: params[:slug])
    end

    def edit
      render partial: 'form'
    end

    def update
      service = ::Clients::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_clients_path(slug: params[:slug])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_clients_path(slug: params[:slug])
    end

    def destroy
      ActiveRecord::Base.transaction do
        client.destroy!
        flash[:success] = "Berhasil!"
        redirect_to admin_clients_path(slug: params[:slug])
      end
    end

    private
      def client
        @client = Client.find_by(id: params[:id])
      end
  end
end
