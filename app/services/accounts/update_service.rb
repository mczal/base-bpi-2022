module Accounts
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      account.assign_attributes(attributes)
      account.save!
    end

    def account
      @account ||= Account.find_by(id: @params[:id])
    end

    private
      def attributes
        @attributes ||= @params.require(:account)
          .permit(
            :code, :name, :balance_type,
            :account_category_id, :isak_16,
            :non_isak, :fiskal, :moneter
          )
      end
  end
end
