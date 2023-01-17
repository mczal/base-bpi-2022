# frozen_string_literal: true

namespace :approval_configuration do
  desc 'Approval Configuration'
  task seed: :environment do
    attr = [
      {
        roles: %w(manager_finance),
      },
      {
        roles: %w(evp_finance),
        bottom_treshold: 50000000,
        upper_treshold: 100000000,
      },
      {
        roles: %w(director_finance),
        bottom_treshold: 100000000,
      },
    ]

    attr.each do |x|
      ApprovalConfiguration.create!(x)
    end
  end
end

