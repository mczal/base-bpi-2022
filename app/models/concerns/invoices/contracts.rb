# frozen_string_literal: true

module Invoices
  module Contracts
    extend ActiveSupport::Concern
    include DateHelper

    def contract_description_html
      <<-EOS
        <div><b>No Ref.:</b> #{contract.ref_number}</div>
        <div><b>Status:</b> #{contract.status_html}</div>
        <div><b>Nilai Kontrak:</b> #{contract.price.to_money.format}</div>
        <div><b>Tanggal:</b> #{readable_date_4 contract.started_at} - #{readable_date_4 contract.ended_at}</div>
        <div><b>Client:</b>
          <div class='ml-2'>
            #{contract.client_description}
          </div>
        </div>
      EOS
    end
  end
end
