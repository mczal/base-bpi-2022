module Bas
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      assign_other_files
      ba.assign_attributes(ba_attributes.except(:other_files))
      ba.status = ba_status
      ba.save!
    end

    def ba
      @ba ||= Ba.find_by(id: @params[:id])
    end

    private
      def assign_other_files
        return unless ba_attributes[:other_files].present?
        ba_attributes[:other_files].each do |other_file|
          ba.other_files.attach(other_file)
        end
      end

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
