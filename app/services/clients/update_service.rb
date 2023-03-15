# frozen_string_literal: true

module Clients
  class UpdateService < BaseService
    def initialize params
      @params = params      
    end

    def run
      client = Client.find_by(id: @params[:id])
      client.assign_attributes(client_params)
      client.save!
    end

    def client_params
      @params.require(:client).permit(:number, :npwp, :name, :phone_number, :email, :address, :group, :pkp_group)
    end

    def company
      @company ||= Company.find_by(slug: :bpi)
    end
  end
end
