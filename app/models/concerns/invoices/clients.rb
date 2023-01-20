# frozen_string_literal: true

module Invoices
  module Clients
    extend ActiveSupport::Concern
    def client_description
      <<-EOS
        <div><b>Email:</b> #{client.email}</div>
        <div><b>Tlp:</b> #{client.phone_number}</div>
        <div><b>Alamat:</b> #{client.address}</div>
        <div><b>No. Tax:</b> #{client.tax_id_number}</div>
      EOS
    end
  end
end
