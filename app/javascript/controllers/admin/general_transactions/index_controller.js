import DatatablesController from '../../datatables_controller';

export default class extends DatatablesController {
  connect(){
    super.connect();
    this.bindChangeDateFilter();
  }

  bindChangeDateFilter(){
    $('#kt_dashboard_datepicker_custom').on('change', function(e) {
      this.datatable.setDataSourceParam('date', e.currentTarget.value);
      this.datatable.load();
    }.bind(this));
  }

  datatableColumns(){
    return [
      {
        field: 'index',
        title: '#',
        sortable: false,
        width: 40,
        type: 'number',
        selector: false,
        textAlign: 'left',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.index}</span>`;
        }
      },
      {
        field: 'date',
        title: 'Tanggal',
        width: 100,
        template: function(data) {
          return `
            <span data-controller="base--popover" data-base--popover-html="1" data-base--popover-trigger="hover" data-content="Dibuat: ${data.created_at} <br/> Diubah: ${data.updated_at}" data-title="Dibuat/Diubah" class="svg-icon svg-icon-light-dark" style="cursor:pointer;">
              <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="24px" height="24px" viewBox="0 0 24 24" version="1.1">
                  <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                      <rect x="0" y="0" width="24" height="24"/>
                      <circle fill="#000000" opacity="0.3" cx="12" cy="12" r="10"/>
                      <rect fill="#000000" x="11" y="10" width="2" height="7" rx="1"/>
                      <rect fill="#000000" x="11" y="7" width="2" height="2" rx="1"/>
                  </g>
              </svg>
            </span>
            <span class="font-weight-bolder">${data.date}</span>
            `;
        }
      },
      {
        field: 'number_evidence',
        title: 'Nomor Bukti',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.number_evidence}</span>`;
        }
      },
      {
        field: 'location',
        title: 'Lokasi',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.location}</span>`;
        }
      },
      {
        field: 'status',
        title: 'Status',
        template: function(data) {
          return `${data.status_html}`;
        }
      },
      {
        field: 'Actions',
        title: 'Actions',
        sortable: false,
        width: 125,
        textAlign: 'center',
        overflow: 'visible',
        autoHide: false,
        template: function(data) {
          return `
            <a href="${data.show_path}" class="btn btn-sm btn-clean btn-icon">
              <i class="la la-eye text-primary"></i>
            </a>
            <a href="javascript:void(0);" class="btn btn-sm btn-clean btn-icon"
              data-toggle="modal"
              data-target="#Edit"
              data-controller="admin--edit"
              data-action="click->admin--edit#handleClick"
              data-admin--edit-path="${data.edit_path}"
            >
              <i class="la la-edit text-warning"></i>
            </a>
            <a href="${data.delete_path}" data-method="delete" data-confirm="Apakah anda yakin ingin menghapus akun ini?" class="btn btn-sm btn-clean btn-icon" title="Delete">
              <i class="la la-trash text-danger"></i>
            </a>
          `;
        },
      }
    ]
  }
}
