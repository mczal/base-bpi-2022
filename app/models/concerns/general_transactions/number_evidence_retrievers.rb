# frozen_string_literal: true

module GeneralTransactions
  module NumberEvidenceRetrievers extend ActiveSupport::Concern
    def retrieve_new_number_evidence location, group
      return nil unless location.present?

      if group == :bj
        latest = GeneralTransaction.select(:number_evidence).distinct
          .where(location: location)
          .where('number_evidence ILIKE ?', 'BJ%')
          .reorder(number_evidence: :desc)
          .limit(1)
          .first&.number_evidence

        if location == 'site'
          latest = latest.to_s.downcase.remove('bj-site-').strip.to_i
          loc_text = '-Site-'
        elsif location == 'jakarta'
          latest = latest.to_s.downcase.remove('bj').strip.to_i
          loc_text = ' '
        end

        return "BJ#{loc_text}#{(latest+1).to_s.rjust(4,'0')}"
      end
    end
  end
end
