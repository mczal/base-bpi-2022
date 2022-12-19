# frozen_string_literal: true

module Api
  module Admin
    module MasterBusinessUnits
      class IndexController < Api::ApplicationController
        def show
          render json: result
        end

        private
        def result
          {
            meta: meta,
            data: data
          }
        end

        def master_business_units
          return @master_business_units if @master_business_units.present?

          @master_business_units = MasterBusinessUnit
            # .where(company_id: current_company.id)
            .order(group: :asc, code: :asc)

          if sort.present?
            @master_business_units = @master_business_units
              .reorder("#{sort[:field]}": sort[:sort])
          end

          if query.present? && query.dig(:search).present?
            @master_business_units = @master_business_units
              .search(query[:search])
          end

          @master_business_units
        end

        def paginated_master_business_units
          @paginated_master_business_units ||= master_business_units
            .page(page[:page])
            .per(page[:perpage])
        end

        def sort
          params[:sort]
        end

        def query
          params[:query]
        end

        def page
          params.require(:pagination)
        end

        def meta
          {
            page: page[:page],
            pages: paginated_master_business_units.total_pages,
            perpage: page[:perpage],
            total: master_business_units.count
          }
        end

        def data
          return @data if @data.present?

          @data = {}
          paginated_master_business_units.each_with_index do |master_business_unit, index|
            i = index + start_index
            @data[i] = {
              index: i,
              id: master_business_unit.id,
              code: master_business_unit.code,
              description: master_business_unit.description,
              group: master_business_unit.group.titlecase,
              edit_path: admin_edit_master_business_unit_path(id: master_business_unit.id,slug: current_company.slug),
              delete_path: admin_master_business_unit_path(id: master_business_unit.id, slug: current_company.slug)
            }
          end

          @data
        end

        def start_index
          if page[:page].to_i <= 1
            return 1
          end

          ((page[:page].to_i - 1) * page[:perpage].to_i) + 1
        end
      end
    end
  end
end
