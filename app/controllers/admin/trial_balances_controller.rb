module Admin
  class TrialBalancesController < AdminController
    before_action :presenter, only: %i[table]

    def index; end

    def table
      render partial: 'table'
    end

    private
      def presenter
        @presenter ||= TrialBalancesPresenter.new(params)
      end
  end
end
