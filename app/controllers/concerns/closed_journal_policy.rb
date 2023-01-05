module ClosedJournalPolicy extend ActiveSupport::Concern
  included do
    before_action :enforce_closed_journal_policy, only: %i[destroy create update]
  end

  def enforce_closed_journal_policy
    is_closed_journal = false

    # Date from params checker
    # All data can't be written for new attribute date vioalate the closed journal policy
    # even for new data or old data that being updated or destroying data
    if params[:general_transaction].present? && params[:general_transaction][:date].present?
      date = Date.strptime(params[:general_transaction][:date], '%d/%m/%Y')
      is_closed_journal = ClosedJournal.where("date >= ?", date).present?
    end
    return forbid_access_by_closed_journal_policy(date) if is_closed_journal

    # Date from entity checker
    # All data that is already on date before closed journal is triggered
    # cannot be modify or destroy
    if params[:id].present? && general_transaction.present?
      date = general_transaction.date
      is_closed_journal = ClosedJournal.where("date >= ?", general_transaction.date).present?
    end
    return forbid_access_by_closed_journal_policy(date) if is_closed_journal
  end

  def forbid_access_by_closed_journal_policy date
    flash[:alert] = "Transaksi sudah di tutup di Tutup Buku dan tidak dapat hapus atau di tambah pada bulan <b>#{helpers.readable_date_4 date}</b>.".html_safe
    return redirect_to admin_general_transactions_path
  end
end
