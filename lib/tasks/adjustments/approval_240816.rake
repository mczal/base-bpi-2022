# frozen_string_literal: true

namespace :adjustments do
  namespace :approval_240816 do
    desc 'Run Adjust Approval per update dated: 240816'
    task run: :environment do
      GeneralTransaction.original.each do |general_transaction|
        next if general_transaction.accepted?
        origin_status = general_transaction.status

        general_transaction.approvals.destroy_all
        general_transaction.generate_approvals

        general_transaction.status = origin_status
        general_transaction.save! if general_transaction.changed?
      end
    end
  end
end
