module Api
  module Admin
    module Bas
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

          def bas
            return @bas if @bas.present?

            @bas = Ba.all
            if sort.present?
              @bas = @bas
                .order("#{sort[:field]}": sort[:sort])
            end

            if query.present?
              apply_filter_from_query
            end

            @bas
          end

          def apply_filter_from_query
            if query.dig(:daterange).present?
              daterange = query[:daterange].split(' - ')
              start_date = Date.strptime(daterange[0], '%d/%m/%Y')
              end_date  = Date.strptime(daterange[1], '%d/%m/%Y')
              @bas = @bas
                .where('date BETWEEN ? AND ?', start_date, end_date)
            end

            if query.dig(:search).present?
              @bas = @bas.search(query[:search])
            end
          end

          def paginated_bas
            @paginated_bas ||= bas
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
              pages: paginated_bas.total_pages,
              perpage: page[:perpage],
              total: bas.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_bas.each_with_index do |ba, index|
              i = index + start_index
              @data[i] = {
                index: i,
                id: ba.id,

                created_at: helpers.readable_timestamp_2(ba.created_at.localtime),
                updated_at: helpers.readable_timestamp_2(ba.updated_at.localtime),

                ref_number: ba.reference_number,
                status: ba.status_html,
                date: helpers.readable_date_4(ba.date),
                levered_at: helpers.readable_date_4(ba.levered_at),
                realized_at: helpers.readable_date_4(ba.realized_at),
                number_of_days_late: ba.number_of_days_late,

                general_transaction_status: ba.general_transactions.first&.status_for_html,

                status_docs: ba.status_docs,
                show_path: admin_inv_trackings_accountings_ba_path(id: ba.id, slug: params[:slug])
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
