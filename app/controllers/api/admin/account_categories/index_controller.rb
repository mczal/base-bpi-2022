# frozen_string_literal: true

module Api
  module Admin
    module AccountCategories
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

        def account_categories
          return @account_categories if @account_categories.present?

          @account_categories = AccountCategory
            # .where(company_id: current_company.id)
            .order(code: :asc)

          if sort.present?
            @account_categories = @account_categories
              .reorder("#{sort[:field]}": sort[:sort])
          end

          if query.present? && query.dig(:search).present?
            @account_categories = @account_categories
              .search(query[:search])
          end

          @account_categories
        end

        def paginated_account_categories
          @paginated_account_categories ||= account_categories
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
            pages: paginated_account_categories.total_pages,
            perpage: page[:perpage],
            total: paginated_account_categories.total_count
          }
        end

        def data
          return @data if @data.present?

          @data = {}
          paginated_account_categories.each_with_index do |account_category, index|
            i = index + start_index
            @data[i] = {
              index: i,
              id: account_category.id,
              code: account_category.code,
              description: account_category.description,
              accounts_count: account_category.accounts.count,
              is_super_admin: current_user.has_role?(:super_admin),
              show_path: admin_account_category_path(id: account_category.id,slug: current_company.slug),
              edit_path: admin_edit_account_category_path(id: account_category.id,slug: current_company.slug),
              delete_path: admin_account_category_path(id: account_category.id, slug: current_company.slug)
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
