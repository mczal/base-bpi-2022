# frozen_string_literal: true

module Api
  module Admin
    module Users
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

        def users
          return @users if @users.present?

          @users = User
            .where(company: current_company)
            .order(created_at: :desc)

          if sort.present?
            @users = @users
              .reorder("#{sort[:field]}": sort[:sort])
          end

          if query.present? && query.dig(:search).present?
            @users = @users
              .search(query[:search])
          end

          @users
        end

        def paginated_users
          @paginated_users ||= users
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
            pages: paginated_users.total_pages,
            perpage: page[:perpage],
            total: users.count
          }
        end

        def data
          return @data if @data.present?

          @data = {}
          paginated_users.each_with_index do |user, index|
            i = index + start_index
            @data[i] = {
              index: i,
              id: user.id,
              email: user.email,
              company_name: user.company.name,
              role_name: user.roles.pluck(:name).map{|x| "<span class='m-1 label label-pill label-inline'>#{x}</span>"}.join(' ').html_safe,
              show_path: admin_user_path(id: user.id, slug: current_company.slug),
              edit_path: admin_edit_user_path(id: user.id,slug: current_company.slug),
              delete_path: admin_user_path(id: user.id, slug: current_company.slug)
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
