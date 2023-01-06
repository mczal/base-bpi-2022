# frozen_string_literal: true

module Api
  module Admin
    module Rates
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

          def rates
            return @rates if @rates.present?
            @rates = Rate.all

            if sort.present?
              @rates = @rates
                .reorder("#{sort[:field]}": sort[:sort])
            end

            if query.present? && query.dig(:search).present?
              @rates = @rates
                .search(query[:search])
            end

            @rates
          end

          def paginated_rates
            @paginated_rates ||= rates
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
              pages: paginated_rates.total_pages,
              perpage: page[:perpage],
              total: paginated_rates.total_count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_rates.each_with_index do |rate, index|
              i = index + start_index
              @data[i] = {
                index: i,
                id: rate.id,
                created_at: helpers.readable_date_4(rate.created_at),
                updated_at: helpers.readable_date_4(rate.updated_at),
                published_date: helpers.readable_date_4(rate.published_date),
                origin: rate.origin.titlecase,
                middle: helpers.print_money(rate.middle),
                edit_path: admin_settings_edit_rate_path(id: rate.id,slug: current_company.slug),
                delete_path: admin_settings_rate_path(id: rate.id, slug: current_company.slug)
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
