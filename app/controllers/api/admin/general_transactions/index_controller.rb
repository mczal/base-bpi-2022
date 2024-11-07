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
              .where(company_id: current_company.id)

            if !current_user.has_role?(:super_admin)
              if current_user.has_role?(:jakarta) && !current_user.has_role?(:site)
                @general_transactions = @general_transactions
                  .where(location: :jakarta)
              end
              if !current_user.has_role?(:jakarta) && current_user.has_role?(:site)
                @general_transactions = @general_transactions
                  .where(location: :site)
              end
            end

            apply_query
            apply_sort

            @general_transactions
          end

          def apply_query
            if date_range.present?
              @general_transactions = @general_transactions
                .where(date: date_range)
            end
            if query.present? && query.dig(:search).present?
              @general_transactions = @general_transactions
                .search(query[:search])
            end

            if params[:number_evidence].present?
              @general_transactions = @general_transactions.where(
                number_evidence: params[:number_evidence]
              )
            end
            if params[:location].present?
              @general_transactions = @general_transactions.where(
                location: params[:location]
              )
            end
            if params[:approver_id].present?
              user = User.find_by(id: params[:approver_id])
              @general_transactions = @general_transactions
                .select('general_transactions.id').distinct
                .joins('JOIN approvals ON general_transactions.id=approvals.approvable_id')
                .where('approvals.status != ?', 'accepted')
                .where('approvals.role': user.roles.pluck(:name))
              @general_transactions = GeneralTransaction.where(id: @general_transactions.ids)
            end
          end

          def apply_sort
            if sort.present?
              @general_transactions = @general_transactions
                .reorder(
                  "#{sort[:field]}": sort[:sort],
                  number_evidence: sort[:sort]
                )
            else
              @general_transactions = @general_transactions
                .reorder(date: :desc, number_evidence: :desc)
            end
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
                status: general_transaction.status,
                status_label_html_class: general_transaction.status_label_html_class,
                status_translate: general_transaction.status_translate,
                location: general_transaction.location.to_s.titlecase,
                date: general_transaction.date.strftime("%d %b %Y"),
                number_evidence: general_transaction.number_evidence || '-',
                source: (general_transaction.source.present? ? I18n.t(general_transaction.source): '-'),
                is_super_admin: current_user.has_role?(:super_admin),
                is_owner: general_transaction.last_log.user_id == current_user.id,
                show_path: admin_general_transaction_path(id: general_transaction.id, slug: current_company.slug),
                edit_path: admin_edit_general_transaction_path(id: general_transaction.id,slug: current_company.slug),
                delete_path: admin_general_transaction_path(id: general_transaction.id, slug: current_company.slug),
                approver: params[:approver_id].present?,
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
            return @date_range if @date_range.present?

            if params[:date].present?
              date = Date.strptime(params[:date], '%m-%Y')
              return @date_range = (date.beginning_of_month..date.end_of_month)
            end
          end
      end
    end
  end
end
