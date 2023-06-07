module Api
  module Admin
    module InvoiceDirectExternals
      class IndexController < Api::ApplicationController
        def show
          render json: result
        end

        private
          def result
            {
              meta: meta,
              data: data
            }
          end

          def invoice_direct_externals
            return @invoice_direct_externals if @invoice_direct_externals.present?

            @invoice_direct_externals = InvoiceDirectExternal.all
            if sort.present?
              @invoice_direct_externals = @invoice_direct_externals
                .order("#{sort[:field]}": sort[:sort])
            end

            if query.present?
              apply_filter_from_query
            end

            @invoice_direct_externals
          end

          def apply_filter_from_query
            if query.dig(:daterange).present?
              daterange = query[:daterange].split(' - ')
              start_date = Date.strptime(daterange[0], '%d/%m/%Y')
              end_date  = Date.strptime(daterange[1], '%d/%m/%Y')
              @invoice_direct_externals = @invoice_direct_externals
                .where('date BETWEEN ? AND ?', start_date, end_date)
            end

            if query.dig(:search).present?
              @invoice_direct_externals = @invoice_direct_externals.search(query[:search])
            end
          end

          def paginated_invoice_direct_externals
            @paginated_invoice_direct_externals ||= invoice_direct_externals
              .page(page[:page])
              .per(page[:perpage])
          end

          def sort
            params[:sort]
          end

          def query
            params[:query]
          end

          def page
            params.require(:pagination)
          end

          def meta
            {
              page: page[:page],
              pages: paginated_invoice_direct_externals.total_pages,
              perpage: page[:perpage],
              total: invoice_direct_externals.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_invoice_direct_externals.each_with_index do |invoice_direct_external, index|
              i = index + start_index
              @data[i] = {
                index: i,
                id: invoice_direct_external.id,

                created_at: helpers.readable_timestamp_2(invoice_direct_external.created_at.localtime),
                updated_at: helpers.readable_timestamp_2(invoice_direct_external.updated_at.localtime),
                price: invoice_direct_external.price.to_money.format,

                status: invoice_direct_external.status_html,

                ref_number: invoice_direct_external.ref_number,
                receipt_number: invoice_direct_external.receipt_number,
                date: helpers.readable_date_4(invoice_direct_external.date),

                tax_receipt_number: invoice_direct_external.tax_receipt_number,
                tax_receipt_date: helpers.readable_date_4(invoice_direct_external.tax_receipt_date),

                general_transaction_invoice_direct_external_paid_status: (invoice_direct_external.general_transactions.invoice_direct_external_paid.first&.status_for_html || 'Belum ada'),

                show_path: admin_invoice_direct_external_path(id: invoice_direct_external.id, slug: params[:slug])
              }
            end

            @data
          end

          def start_index
            if page[:page].to_i <= 1
              return 1
            end

            ((page[:page].to_i - 1) * page[:perpage].to_i) + 1
          end
      end
    end
  end
end
