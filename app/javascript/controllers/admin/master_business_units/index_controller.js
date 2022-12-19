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
        field: 'group',
        title: 'Tipe',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.group}</span>`;
        }
      },
      {
        field: 'Actions',
        title: 'Actions',
        sortable: false,
        width: 100,
        overflow: 'visible',
        autoHide: false,
        template: function(data) {
          return `
            <a href="javascript:void(0);" class="btn btn-sm btn-clean btn-icon"
              data-toggle="modal"
              data-target="#Edit"
              data-controller="admin--edit"
              data-action="click->admin--edit#handleClick"
              data-admin--edit-path="${data.edit_path}"
            >
              <i class="la la-edit"></i>
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
