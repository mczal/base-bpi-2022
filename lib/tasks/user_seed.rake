# frozen_string_literal: true

namespace :user do
  desc 'User and Roles'
  task seed: :environment do
    company = Company.find_or_initialize_by(
      name: "PT Bukit Pembangkit Innovative",
      codename: 'BPI',
      slug: "bpi",
    )
    company.assign_attributes(
      address: "Surveyor Indonesia Lt 17 Suite 1703, Jl. Jend. Gatot Subroto Kav. 56, Jakarta 12950, Indonesia"
    )
    company.save!

    user = User.find_or_initialize_by(email: "admin@wellcode.io")
    user.password = "admin123"
    user.company = company
    user.save!

    user.add_role :super_admin
    user.add_role :manager_finance
    user.add_role :evp_finance
    user.add_role :director_finance
  end
end
