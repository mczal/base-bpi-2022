# frozen_string_literal: true

module Api
  module Admin
    module Journals
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

          def journals
            return @journals if @journals.present?

            @journals = Journal
              .where(company_id: current_company.id)
              .order(date: :desc)
            if date_range.present?
              @journals = @journals
                .where(date: date_range)
            end

            if sort.present?
              @journals = @journals
                .reorder(
                  "#{sort[:field]}": sort[:sort],
                  number_evidence: sort[:sort]
                )
            else
              @journals = @journals
                .reorder(date: :desc, number_evidence: :desc)
            end

            if query.present? && query.dig(:search).present?
              @journals = @journals
                .search(query[:search])
            end

            @journals
          end

          def paginated_journals
            @paginated_journals ||= journals
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
              pages: paginated_journals.total_pages,
              perpage: page[:perpage],
              total: paginated_journals.total_count
            }
          end

          def data
            return @data if @data.present?

            @data = {}
            paginated_journals.each_with_index do |journal, index|
              i = index + start_index

              # if !@number_evidence.present? || @number_evidence != journal.number_evidence
                number_evidence = journal.number_evidence
                date = helpers.readable_date_3(journal.date)
              # else
                # number_evidence = ''
                # date = ''
              # end

              @data[i] = {
                index: i,
                id: journal.id,
                created_at: helpers.readable_timestamp_4(journal.created_at.localtime),
                updated_at: helpers.readable_timestamp_4(journal.updated_at.localtime),
                date: date,
                code: journal.code,
                account_name: journal.account.name,
                account_category_description: journal.account.account_category.description,
                account_category_range: journal.account.account_category.code,
                number_evidence: number_evidence,
                description: journal.description,
                debit_idr: (journal.debit_idr != 0 ? helpers.print_money(journal.debit_idr) : '-'),
                credit_idr: (journal.credit_idr != 0 ? helpers.print_money(journal.credit_idr) : '-'),
                debit_usd: (journal.debit_usd != 0 ? helpers.print_money(journal.debit_usd) : '-'),
                credit_usd: (journal.credit_usd != 0 ? helpers.print_money(journal.credit_usd) : '-'),
                rates_value: helpers.print_money(journal.rate_money),
                source_path: journal.source_path,
                delete_path: admin_journal_path(id: journal.id, slug: current_company.slug)
              }
              @number_evidence = journal.number_evidence
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
              date = Date.strptime(params[:date], '%m-%Y')
              return @date_range = (date.beginning_of_month..date.end_of_month)
            end
          end
      end
    end
  end
end
