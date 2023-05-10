# frozen_string_literal: true

module Api
  module Admin
    module AuditAdjustments
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

          def audit_adjustments
            return @audit_adjustments if @audit_adjustments.present?
            @audit_adjustments = AuditAdjustment.all

            apply_query
            apply_sort

            @audit_adjustments
          end

          def apply_query
            if date_range.present?
              @audit_adjustments = @audit_adjustments
                .where(date: date_range)
            end
            if query.present? && query.dig(:search).present?
              @audit_adjustments = @audit_adjustments
                .search(query[:search])
            end
          end

          def apply_sort
            if sort.present?
              @audit_adjustments = @audit_adjustments
                .reorder("#{sort[:field]}": sort[:sort])
            end
          end

          def paginated_audit_adjustments
            @paginated_audit_adjustments ||= audit_adjustments
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
              pages: paginated_audit_adjustments.total_pages,
              perpage: page[:perpage],
              total: audit_adjustments.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_audit_adjustments.each_with_index do |audit_adjustment, index|
              i = index + start_index
              @data[i] = {
                index: i,
                created_at: helpers.readable_timestamp_2(audit_adjustment.created_at.localtime),
                updated_at: helpers.readable_timestamp_2(audit_adjustment.updated_at.localtime),
                date: helpers.readable_date_4(audit_adjustment.date),
                number_of_account: audit_adjustment.account_count,
                number_evidence: audit_adjustment.number_evidence || '-',
                status_html: audit_adjustment.status_for_html,
                show_path: admin_audit_adjustment_path(id: audit_adjustment.id, slug: current_company.slug),
                edit_path: admin_edit_audit_adjustment_path(id: audit_adjustment.id, slug: current_company.slug),
                delete_path: admin_audit_adjustment_path(id: audit_adjustment.id, slug: current_company.slug)
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

          def date_range
            return @date_range if @date_range.present?

            if params[:date].present?
              date = Date.strptime(params[:date], '%Y')
              return @date_range = date
            end
          end
      end
    end
  end
end
