module Admin
  module GeneralTransactions
    class PrintoutsController < ::Admin::ApplicationController
      before_action :general_transaction, only: :show

      def show
        respond_to do |format|
          format.pdf {
            pdf = WickedPdf.new.pdf_from_string(
              render_to_string(layout: false),
              orientation: 'Portrait',
              page_size: 'A4',
              margin: { bottom: 10 },
              footer: {
                content: render_to_string('shared/printouts/footer', layout: false),
                right: 'Hal [page] dari [topage]',
                font_size: 7
              }
            )
            general_transaction.refresh_printout!(pdf)
            redirect_to url_for(general_transaction.printout)
          }
        end
      end

      private
        def general_transaction
          @general_transaction ||= GeneralTransaction.find_by(id: params[:id])
        end
    end
  end
end

