import DatatablesController from '../../datatables_controller';

export default class extends DatatablesController {
  datatableColumns(){
    return [
      {
        field: 'no',
        title: 'No',
        autoHide: false,
        width: 45,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.index}</span>`;
        }
      },
      {
        field: 'tax_id_number',
        title: 'No. NPWP/NIK',
        autoHide: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.npwp}</span>`;
        }
      },
      {
        field: 'name',
        title: 'Nama Entitas',
        autoHide: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.name}</span>`;
        }
      },
      {
        field: 'phone_number',
        title: 'Nomor Hp',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.phone_number}</span>`;
        }
      },
      {
        field: 'email',
        title: 'Email',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.email}</span>`;
        }
      },
      {
        field: 'address',
        title: 'Alamat',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.address}</span>`;
        }
      },
      {
        field: 'client_type',
        title: 'Tipe Klien',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.group}</span>`;
        }
      },
      {
        field: 'taxable_employer',
        title: 'Jenis PKP',
        autoHide: false,
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.pkp_group}</span>`;
        }
      },
      {
        field: 'Actions',
        title: 'Actions',
        sortable: false,
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

