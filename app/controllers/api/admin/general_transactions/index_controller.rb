# frozen_string_literal: true

module Api
  module Admin
    module GeneralTransactions
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

          def general_transactions
            return @general_transactions if @general_transactions.present?

            @general_transactions = GeneralTransaction
              .where(company_id: current_company.id, date: date_range)
              .order(date: :desc)

            if sort.present?
              @general_transactions = @general_transactions
                .reorder("#{sort[:field]}": sort[:sort])
            end

            if query.present? && query.dig(:search).present?
              @general_transactions = @general_transactions
                .search(query[:search])
            end

            @general_transactions
          end

          def paginated_general_transactions
            @paginated_general_transactions ||= general_transactions
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
              pages: paginated_general_transactions.total_pages,
              perpage: page[:perpage],
              total: paginated_general_transactions.total_count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_general_transactions.each_with_index do |general_transaction, index|
              i = index + start_index
              @data[i] = {
                index: i,
                id: general_transaction.id,
                created_at: helpers.readable_timestamp_2(general_transaction.created_at.localtime),
                updated_at: helpers.readable_timestamp_2(general_transaction.updated_at.localtime),
                status_html: general_transaction.status_for_html,
                date: general_transaction.date.strftime("%d %b %Y"),
                number_evidence: general_transaction.number_evidence,
                show_path: admin_general_transaction_path(id: general_transaction.id, slug: current_company.slug),
                delete_path: admin_general_transaction_path(id: general_transaction.id, slug: current_company.slug)
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

          def date_range
            if params[:start_date].present? && params[:end_date].present?
              return (params[:start_date].to_date..params[:end_date].to_date)
            end
            return (Date.today.beginning_of_year..Date.today.end_of_month)
          end
      end
    end
  end
end
