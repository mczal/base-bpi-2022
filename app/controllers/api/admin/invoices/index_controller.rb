module Api
  module Admin
    module Invoices
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

          def invoices
            return @invoices if @invoices.present?

            @invoices = Invoice.all
            if sort.present?
              @invoices = @invoices
                .order("#{sort[:field]}": sort[:sort])
            end

            if query.present?
              apply_filter_from_query
            end

            @invoices
          end

          def apply_filter_from_query
            if query.dig(:daterange).present?
              daterange = query[:daterange].split(' - ')
              start_date = Date.strptime(daterange[0], '%d/%m/%Y')
              end_date  = Date.strptime(daterange[1], '%d/%m/%Y')
              @invoices = @invoices
                .where('date::date BETWEEN ? AND ?', start_date, end_date)
            end

            if query.dig(:search).present?
              @invoices = @invoices.search(query[:search])
            end
          end

          def paginated_invoices
            @paginated_invoices ||= invoices
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
              pages: paginated_invoices.total_pages,
              perpage: page[:perpage],
              total: invoices.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_invoices.each_with_index do |invoice, index|
              i = index + start_index
              @data[i] = {
                index: i,
                id: invoice.id,

                created_at: helpers.readable_timestamp_2(invoice.created_at.localtime),
                updated_at: helpers.readable_timestamp_2(invoice.updated_at.localtime),
                price: invoice.ba.price.to_money.format,

                status: invoice.status_html,

                spp_number: invoice.spp_number,
                ref_number: invoice.ref_number,
                receipt_number: invoice.receipt_number,
                date: helpers.readable_date_4(invoice.date),

                tax_receipt_number: invoice.tax_receipt_number,
                tax_receipt_date: helpers.readable_date_4(invoice.tax_receipt_date),

                show_path: admin_inv_trackings_finances_invoice_path(id: invoice.id, slug: params[:slug])
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
