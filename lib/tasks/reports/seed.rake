# frozen_string_literal: true

namespace :reports do
  namespace :seed do
    desc 'Seed report from beginning balance'
    task run: :environment do
      service = ::Reports::SeedService.new
      service.run
    end
  end
end


