module Bas
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      ba.save!
    end

    def ba
      return @ba if @ba.present?
      @ba = Ba.new(ba_attributes)
      @ba.status = ba_status
      @ba
    end

    private
      def ba_status
        return :ok if @params[:submit_button] != 'Simpan as Draft'
        :draft
      end

      def ba_attributes
        @params.require(:ba).permit(
          :contract_id, :reference_number, :description,
          :date, :levered_at, :realized_at,
          :accrued_credit_id, :price,
          :price_currency,
          :file, other_files: []
        )
      end
  end
end
