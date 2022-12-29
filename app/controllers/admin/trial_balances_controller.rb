module Admin
  class TrialBalancesController < AdminController
    def index; end

    def table
      render partial: 'table'
    end
  end
end
