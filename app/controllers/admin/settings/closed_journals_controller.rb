# frozen_string_literal: true

module Admin
  module Settings
    class ClosedJournalsController < Admin::ReportsController
      def index
        @closed_journals = ClosedJournal.all
        @closed_journal = ClosedJournal.new
      end

      def create
        @closed_journal = ClosedJournal.new(closed_journal_params)
        @closed_journal.name = "Jurnal ditutup tanggal #{@closed_journal.date.strftime('%d %B %Y')}"
        if @closed_journal.save
          return redirect_to admin_settings_closed_journals_path, notice: 'Closed journal was successfully updated.'
        end

        redirect_to admin_settings_closed_journals_path, alert: @closed_journal.errors.errors.full_messages.to_sentence
      end

      def destroy
        @closed_journal = ClosedJournal.find(params[:id])
        @closed_journal.destroy
        return redirect_to admin_settings_closed_journals_path, notice: 'Closed journal was successfully destroyed.'
      end
      private
      def closed_journal_params
        params.require(:closed_journal).permit(:name, :date)
      end
    end
  end
end
