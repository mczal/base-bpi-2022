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
        field: 'description',
        title: 'Deskripsi',
        width: 150,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.description}</span>`;
        }
      },
      {
        field: 'accounts_count',
        title: 'Jumlah Akun',
        width: 80,
        textAlign: 'center',
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.accounts_count}</span>`;
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
            <a href="${data.show_path}" class="btn btn-sm btn-clean btn-icon" title="Detil">
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