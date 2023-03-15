# frozen_string_literal: true

module Api
  module Admin
    module Clients
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

          def clients
            return @clients if @clients.present?
            @clients = Client.all.order(name: :asc)

            if sort.present?
              @clients = @clients
                .reorder("#{sort[:field]}": sort[:sort])
            end
            if query.present? && query.dig(:search).present?
              @clients = @clients
                .search(query[:search])
            end

            @clients
          end

          def paginated_clients
            @paginated_clients ||= clients
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
              pages: paginated_clients.total_pages,
              perpage: page[:perpage],
              total: clients.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_clients.each_with_index do |client, index|
              i = index + start_index

              @data[i] = {
                index: i,
                name: client.name,
                email: client.email,
                phone_number: client.phone_number,
                address: client.address,
                npwp: client.npwp,
                group: client.group.to_s.titlecase,
                pkp_group: client.pkp_group.to_s.titlecase.upcase,
                show_path: admin_client_path(id: client.id, slug: current_company.slug),
                edit_path: admin_edit_client_path(id: client.id, slug: current_company.slug),
                delete_path: admin_client_path(id: client.id, slug: current_company.slug)
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
