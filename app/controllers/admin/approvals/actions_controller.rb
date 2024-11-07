module Admin
  module Approvals
    class ActionsController < ::AdminController
      def bulk_approve
        ActiveRecord::Base.transaction do
          approvals.update(
            status: :accepted,
            audit_comment: 'OK <From Bulk Approval>'
          )
        end

        head :ok
      end

      private
        def approvals
          @approvals ||= ::Approval
            .where(approvable_type: 'GeneralTransaction')
            .where(approvable_id: general_transactions.ids)
            .where(role: current_user.roles.pluck(:name))
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

          if params[:selectedAllRows]
            apply_query
          else
            @general_transactions = @general_transactions.where(id: params[:ids])
          end

          @general_transactions = @general_transactions.where.not(status: :accepted)
        end

        def apply_query
          if date_range.present?
            @general_transactions = @general_transactions
              .where(date: date_range)
          end
          if params[:querySearch]
            @general_transactions = @general_transactions
              .search(params[:querySearch])
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
        end

        def date_range
          return @date_range if @date_range.present?
          return nil unless params[:date].present?

          date = Date.strptime(params[:date], '%m-%Y')
          @date_range = (date.beginning_of_month..date.end_of_month)
        end
    end
  end
end
