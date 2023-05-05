# frozen_string_literal: true

module GeneralTransactions
  module NumberEvidenceRetrievers extend ActiveSupport::Concern
    def retrieve_new_number_evidence location, group, cash_account:nil
      return nil unless location.present?

      if group == :bj
        latest = GeneralTransaction.select(:number_evidence).distinct
          .where(location: location)
          .where('number_evidence ILIKE ?', 'BJ%')
          .reorder(number_evidence: :desc)
          .limit(1)
          .first&.number_evidence
        latest_from_reval = Reval.select(:number_evidence).distinct
          .where('number_evidence ILIKE ?', 'BJ%')
          .reorder(number_evidence: :desc)
          .limit(1)
          .first&.number_evidence

        if location == 'site'
          latest = latest.to_s.downcase.remove('bj-site-').strip.to_i
          loc_text = '-Site-'
        elsif location == 'jakarta'
          latest = latest.to_s.downcase.remove('bj').strip.to_i
          latest_from_reval = latest_from_reval.to_s.downcase.remove('bj').strip.to_i
          latest = latest_from_reval if latest_from_reval > latest
          loc_text = ' '
        end

        return "BJ#{loc_text}#{(latest+1).to_s.rjust(4,'0')}"
      end
      if group == :cash
        return nil if !cash_account.present?

        c = cash_account.name.last(3)
        latest = GeneralTransaction.select(:number_evidence).distinct
          .where('number_evidence ILIKE ?', "BNI-#{c}-%")
          .reorder(number_evidence: :desc)
          .limit(1)
          .first&.number_evidence
        latest = latest.to_s.last(3).to_i + 1

        return "BNI-#{c}-#{latest.to_s.rjust(3, '0')}"
      end
    end
  end
end
