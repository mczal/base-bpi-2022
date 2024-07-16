# frozen_string_literal: true

module Api
  module Admin
    module Accounts
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

          def accounts
            return @accounts if @accounts.present?

            @accounts = Account
              .where(company_id: current_company.id)
              .order(code: :asc)

            if sort.present?
              @accounts = @accounts
                .reorder("#{sort[:field]}": sort[:sort])
            end

            if query.present? && query.dig(:search).present?
              @accounts = @accounts
                .search(query[:search])
            end
            if params[:account_category_id].present?
              @accounts = @accounts
                .where(account_category_id: params[:account_category_id])
            end

            @accounts
          end

          def paginated_accounts
            @paginated_accounts ||= accounts
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
              pages: paginated_accounts.total_pages,
              perpage: page[:perpage],
              total: accounts.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_accounts.each_with_index do |account, index|
              i = index + start_index
              @data[i] = {
                index: i,
                id: account.id,
                code: account.code,
                name: account.name,
                company_name: account.company.name,
                balance_type: account.balance_type,
                moneter: account.moneter?,
                report_categories: account.report_categories_for_checkbox,
                account_category: account.account_category.description,
                is_super_admin: current_user.has_role?(:super_admin),
                edit_path: admin_edit_account_path(id: account.id,slug: current_company.slug),
                delete_path: admin_account_path(id: account.id, slug: current_company.slug)
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
