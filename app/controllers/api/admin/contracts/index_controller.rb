module Api
  module Admin
    module Contracts
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

          def contracts
            return @contracts if @contracts.present?

            @contracts = Contract.all
            if sort.present?
              @contracts = @contracts
                .order("#{sort[:field]}": sort[:sort])
            end

            if query.present?
              apply_filter_from_query
            end

            @contracts
          end

          def apply_filter_from_query
            if query.dig(:daterange).present?
              daterange = query[:daterange].split(' - ')
              start_date = Date.strptime(daterange[0], '%d/%m/%Y')
              end_date  = Date.strptime(daterange[1], '%d/%m/%Y')
              @contracts = @contracts
                .where('date::date BETWEEN ? AND ?', start_date, end_date)
            end

            if query.dig(:search).present?
              @contracts = @contracts.search(query[:search])
            end
          end

          def paginated_contracts
            @paginated_contracts ||= contracts
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
              pages: paginated_contracts.total_pages,
              perpage: page[:perpage],
              total: contracts.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_contracts.each_with_index do |contract, index|
              i = index + start_index
              @data[i] = {
                index: i,
                id: contract.id,

                created_at: helpers.readable_timestamp_2(contract.created_at.localtime),
                updated_at: helpers.readable_timestamp_2(contract.updated_at.localtime),

                ref_number: contract.ref_number,
                status: contract.status_html,
                status_description: contract.status_description_html,
                started_at: helpers.readable_date_4(contract.started_at),
                ended_at: helpers.readable_date_4(contract.ended_at),

                started_with_group: contract.started_with_group.to_s.upcase,
                started_with_date: helpers.readable_date_4(contract.started_with_date),
                started_with_ref_number: contract.started_with_ref_number || '-',

                time_period: contract.time_period,
                payment_time_period_group: I18n.t(contract.payment_time_period_group).titlecase,
                payment_time_period: contract.payment_time_period,

                status_docs: contract.status_docs,
                ended_at: helpers.readable_date_4(contract.ended_at),
                price: contract.price.to_money.format,
                show_path: admin_inv_trackings_procurements_contract_path(id: contract.id, slug: params[:slug])
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
