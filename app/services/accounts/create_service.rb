module Accounts
  class CreateService < ::BaseService
    def initialize params, current_company
      @params = params
      @current_company = current_company
    end

    def action
      account.save!
    end

    def account
      @account ||= Account.new(attributes)
    end

    private
      def attributes
        @attributes ||= @params.require(:account)
          .permit(
            :code, :name, :balance_type,
            :account_category_id, :isak_16,
            :non_isak, :fiskal
          ).merge({
            company_id: @current_company.id
          })
      end
  end
end
