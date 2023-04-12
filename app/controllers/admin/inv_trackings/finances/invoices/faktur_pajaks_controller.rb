module Admin
  module InvTrackings
    module Finances
      module Invoices
        class FakturPajaksController < ::Admin::InvTrackings::Finances::ApplicationController
          def verify
            if params[:group] == 'png'
              service = FakturPajaks::ScannerPngService.new(params)
            elsif params[:group] == 'pdf'
              service = FakturPajaks::ScannerPdfService.new(params)
            end

            if !service.run
              return render json: {
                is_succeed: false,
                message: "Gagal, #{service.full_error_messages_html}"
              }, status: :bad_request
            end

            @faktur_pajak = service.faktur_pajak
            return render json: {
              is_succeed: true,
              message: "Berhasil!",
              html: render_to_string(layout: false)
            }
          end
        end
      end
    end
  end
end

