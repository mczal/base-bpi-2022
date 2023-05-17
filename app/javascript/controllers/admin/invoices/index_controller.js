import DatatablesController from 'controllers/datatables_controller';

export default class extends DatatablesController {
  initialize(){
    super.initialize();
    this.bindedHandleReloadEvent = this.handleReloadEvent.bind(this);
  }

  connect(){
    this.bindReload();
    super.connect();
    this.bindChangeDateFilter();
  }

  disconnect(){
    window.removeEventListener(
      `${this.data.get('reloadSubjectId')}-datatable:reload`,
      this.bindedHandleReloadEvent
    );
  }

  bindChangeDateFilter(){
    $('#kt_dashboard_daterangepicker_custom').on('apply.daterangepicker', function(ev, picker) {
      const startDate = picker.startDate.format('DD/MM/YYYY');
      const endDate = picker.endDate.format('DD/MM/YYYY');
      this.datatable.search(`${startDate} - ${endDate}`, "daterange");
    }.bind(this));
  }

  bindReload(){
    const eventName = `${this.data.get('reloadSubjectId')}-datatable:reload`;
    console.log('DataTaBle: EventName', eventName);
    window.addEventListener(
      eventName, this.bindedHandleReloadEvent
    );
  }

  handleReloadEvent(){
    this.datatable.reload();
  }

  datatableColumns(){
    return [
      {
        field: 'index',
        title: '#',
        sortable: false,
        width: 40,
        type: 'number',
        autoHide: false,
        selector: false,
        textAlign: 'left',
        template: function(data) {
          return `<span class="font-weight-bolder">
            ${data.index}
            </span>`;
        }
      },
      {
        field: 'date',
        title: 'Invoice',
        autoHide: false,
        template: function(data) {
          return `
            <span data-controller="base--popover" data-base--popover-html="1" data-base--popover-trigger="hover" data-content="Dibuat: ${data.created_at} <br/> Diubah: ${data.updated_at}" data-title="Dibuat/Diubah" class="svg-icon svg-icon-light-dark" style="cursor:pointer;" data-original-title="" title="">
              <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="24px" height="24px" viewBox="0 0 24 24" version="1.1">
                <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                  <rect x="0" y="0" width="24" height="24"></rect>
                  <circle fill="#000000" opacity="0.3" cx="12" cy="12" r="10"></circle>
                  <rect fill="#000000" x="11" y="10" width="2" height="7" rx="1"></rect>
                  <rect fill="#000000" x="11" y="7" width="2" height="2" rx="1"></rect>
                </g>
              </svg>
            </span>
            <a href="javascript:void(0);" class="text-dark-75 font-weight-bolder text-hover-primary mb-1 font-size-lg">
              ${data.ref_number}
            </a>
            <div>
              <span class="font-weight-bolder">
              Tgl:
              </span>
              <a class="text-muted font-weight-bold text-hover-primary" href="javascript:void(0);">
              ${data.date}
              </a>
            </div>
          `;
        }
      },
      {
        field: 'receipt_number',
        title: 'SPP/Kwitansi',
        width: 100,
        template: function(data) {
          return `
          <div>
            <span class="font-weight-bolder">
            SPP:
            </span>
            <a class="text-muted font-weight-bold text-hover-primary" href="javascript:void(0);">
            ${data.spp_number}
            </a>
          </div>
          <div>
            <span class="font-weight-bolder">
            Kwitansi:
            </span>
            <a class="text-muted font-weight-bold text-hover-primary" href="javascript:void(0);">
            ${data.receipt_number}
            </a>
          </div>
          `;
        }
      },
      {
        field: 'price',
        title: 'Nilai',
        autoHide: false,
        width: 170,
        template: function(data) {
          return `${data.price}`;
        }
      },
      {
        field: 'status',
        title: 'Status',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `
            ${data.status}
          `;
        }
      },
      {
        field: 'status_general_transaction_invoice_approved',
        title: 'Status Transaksi Verifikasi Invoice (Jurnal Hutang)',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `
            ${data.general_transaction_invoice_approved_status}
          `;
        }
      },
      {
        field: 'status_general_transaction_invoice_paid',
        title: 'Status Transaksi Paid Invoice  (Jurnal Kas)',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `
            ${data.general_transaction_invoice_paid_status}
          `;
        }
      },
      {
        field: 'Actions',
        title: 'Actions',
        sortable: false,
        autoHide: false,
        template: function(data) {
          return `
            <a href="${data.show_path}" class="btn btn-sm btn-clean btn-icon btn-hover-light-primary">
              <i class="la la-eye"></i>
            </a>
          `;
        }
      },
    ]
  }
}
