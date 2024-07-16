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
        autoHide: false,
        overflow: 'visible',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.index}</span>`;
        }
      },
      {
        field: 'created_at',
        title: 'Dibuat',
        width: 100,
        overflow: 'visible',
        autoHide: false,
        template: function(data) {
          return `
            <span class="font-weight-bolder">${data.created_at}</span>
            `;
        }
      },
      {
        field: 'action',
        title: 'Action',
        sortable: false,
        template: function(data) {
          return `${data.action}`;
        }
      },
      {
        field: 'user',
        title: 'User',
        sortable: false,
        template: function(data) {
          return `
            <span class="font-weight-bolder">
              ${data.user}
            </span>
          `;
        }
      },
      {
        field: 'version',
        title: 'Version',
        sortable: false,
        template: function(data) {
          return `${data.version}`;
        }
      },
      {
        field: 'a',
        title: '',
        sortable: false,
        template: function(data) {
          return ``;
        }
      },
      {
        field: 'b',
        title: '',
        sortable: false,
        template: function(data) {
          return ``;
        }
      },
      {
        field: 'audited_changes',
        title: 'Changes',
        sortable: false,
        autoHide: true,
        template: function(data) {
          return `${data.audited_changes}`;
        }
      },
    ]
  }
}
