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
        field: 'email',
        title: 'Email',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.email}</span>`;
        }
      },
      {
        field: 'company',
        title: 'Nama Perusahaan',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.company_name}</span>`;
        }
      },
      {
        field: 'role',
        title: 'Role',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.role_name}</span>`;
        }
      },
      {
        field: 'Actions',
        title: 'Actions',
        sortable: false,
        width: 150,
        overflow: 'visible',
        autoHide: false,
        template: function(data) {
          return `
            <!--
            <a href="${data.show_path}" class="btn btn-sm btn-clean btn-icon">
              <i class="la la-eye"></i>
            </a>
            -->
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
