# frozen_string_literal: true

module Api
  module Admin
    module DataHistories
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

          def audits
            return @audits if @audits.present?
            @audits = Audit
              .where(
                auditable_id: params[:auditable_id],
                auditable_type: params[:auditable_type]
              )
              .or(
                Audit.where(
                  associated_id: params[:auditable_id],
                  associated_type: params[:auditable_type]
                )
              )

            if sort.present?
              @audits = @audits
                .reorder(sort['field'] => sort['sort'])
            end

            @audits
          end

          def paginated_audits
            @paginated_audits ||= audits
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
              pages: paginated_audits.total_pages,
              perpage: page[:perpage],
              total: audits.count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_audits.each_with_index do |audit, index|
              i = index + start_index
              @data[i] = {
                index: i,
                user: {
                  name: (audit.user&.name || '-')
                },
                created_at: helpers.readable_timestamp_2(audit.created_at.localtime),
                version: audit.version,
                action: audit.action,
                comment: (audit.comment || '-'),
                audited_changes: audit.readable_changes_html,
                type: audit.auditable_type,
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
