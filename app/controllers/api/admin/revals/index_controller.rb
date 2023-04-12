# frozen_string_literal: true

module Api
  module Admin
    module Revals
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

          def revals
            return @revals if @revals.present?
            @revals = Reval.all

            if sort.present?
              @revals = @revals
                .reorder("#{sort[:field]}": sort[:sort])
            end
            if query.present? && query.dig(:search).present?
              @revals = @revals
                .search(query[:search])
            end

            @revals
          end

          def paginated_revals
            @paginated_revals ||= revals
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
              pages: paginated_revals.total_pages,
              perpage: page[:perpage],
              total: revals.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_revals.each_with_index do |reval, index|
              i = index + start_index
              @data[i] = {
                index: i,
                created_at: helpers.readable_timestamp_2(reval.created_at.localtime),
                updated_at: helpers.readable_timestamp_2(reval.updated_at.localtime),
                date: helpers.readable_date_4(reval.date),
                number_of_account: reval.reval_lines.debit.count,
                show_path: admin_reval_path(id: reval.id, slug: current_company.slug),
                edit_path: admin_edit_reval_path(id: reval.id, slug: current_company.slug),
                delete_path: admin_reval_path(id: reval.id, slug: current_company.slug)
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
