# frozen_string_literal: true

module Clients
  class CreateService < BaseService
    def initialize params
      @params = params
    end

    def run
      new_client = Client.new(client_params)      
      new_client.company = company
      new_client.save
    end

    def client_params
      @params.require(:client).permit(:number, :npwp, :name, :phone_number, :email, :address, :group, :pkp_group)
    end

    def company
      @company ||= Company.find_by(slug: :bpi)
    end
  end
end
