# frozen_string_literal: true

module Contracts
  module Clients extend ActiveSupport::Concern
    def client_description
      <<-EOS
        <div><b>Email:</b> #{client.email}</div>
        <div><b>Tlp:</b> #{client.phone_number}</div>
        <div><b>Alamat:</b> #{client.address}</div>
        <div><b>No. Tax:</b> #{client.npwp}</div>
      EOS
    end
  end
end
