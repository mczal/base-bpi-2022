import DatatablesController from '../../datatables_controller';

export default class extends DatatablesController {
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
        field: 'code',
        title: 'Kode Akun',
        width: 100,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.code}</span>`;
        }
      },
      {
        field: 'name',
        title: 'Nama Akun',
        width: 150,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.name}</span>`;
        }
      },
      {
        field: 'balance_type',
        title: 'Tipe Saldo',
        width: 80,
        textAlign: 'center',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.balance_type}</span>`;
        }
      },
      {
        field: 'report_category',
        width: 180,
        title: 'Kategori Laporan',
        textAlign: 'center',
        template: function(data) {
          let result = '';
          for(let i=0; i<data.report_categories.length; i++){
            result += `
              <span
                class="switch switch-outline switch-icon switch-success flex-column"
                data-controller="admin--accounts--report-category-updater"
                data-admin--accounts--report-category-updater-path="#"
              >
                ${data.report_categories[i]}
              </span>
            `;
          }

          return `
            <div class="d-flex">
              ${result}
            </div>
          `;
        }
      },
      {
        field: 'account_category',
        title: 'Kategori',
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.account_category}</span>`;
        }
      },
      {
        field: 'Actions',
        title: 'Actions',
        sortable: false,
        width: 120,
        overflow: 'visible',
        autoHide: false,
        template: function(data) {
          return `
            <a href="${data.delete_path}" class="btn btn-sm btn-clean btn-icon">
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
