import DatatablesController from '../../datatables_controller';

export default class extends DatatablesController {
  initialize(){
    super.initialize();
    this.filter = document.querySelector('[data-controller="admin--index-filter"]');
    this.filterTriggerer = this.filter.querySelector('[data-admin--index-filter-target="filterTriggerer"]');
  }

  connect(){
    super.connect();
    //debugger;
    window.generalTransactionDatatable = this.datatable;

    this.bindChangeDateFilter();
    this.bindFilter();
    this.bindOnClickCheckbox();

  }

  //debugger;
  disconnect(){
    //debugger;
    window.generalTransactionDatatable = null;
  }

  bindOnClickCheckbox(){
    this.datatable.on(
      // 'datatable-on-check datatable-on-uncheck',
      'datatable-on-click-checkbox',
      this.handleOnClickCheckbox.bind(this)
    );
  }
  handleOnClickCheckbox(e){
    // datatable.checkbox() access to extension methods
    let ids = [...new Set(this.datatable.checkbox().getSelectedId())];
    let count = ids.length;
    if(this.datatable.checkbox().selectedAllRows){
      const token = $('.datatable-pager-detail').text().split('of');
      count = parseInt(token[token.length-1]);
    }

    $('#kt_datatable_selected_records_2').html(count);

    if (count > 0) {
      $('#kt_datatable_group_action_form_2').collapse('show');
    } else {
      $('#kt_datatable_group_action_form_2').collapse('hide');
    }

    const event = new CustomEvent('datatable:checkbox-updated', {detail: {
      ids: ids,
      count: count,
      selectedAllRows: this.datatable.checkbox().selectedAllRows,
    }});
    this.element.dispatchEvent(event);
  }

  bindFilter(){
    this.filterTriggerer.addEventListener('click', (e) => {
      window.KTApp.blockPage();
      const params = [];

      const inputs = this.filter.querySelectorAll('input,select');
      for(let i=0 ;i<inputs.length; i++){
        if(inputs[i].type === 'radio'){
          if(inputs[i].checked){
            params.push({
              name: inputs[i].name,
              value: inputs[i].value
            });
          }
        } else if(inputs[i].tagName === 'SELECT'){
          const selectedOption = inputs[i].selectedOptions[0]
          if(selectedOption){
            params.push({
              name: inputs[i].name,
              value: selectedOption.value
            });
          }
        } else {
          params.push({
            name: inputs[i].name,
            value: inputs[i].value
          });
        }
      }

      if(params.length > 0){
        params.forEach((entry) => {
          this.datatable.setDataSourceParam(entry.name, entry.value);
          this.datatable.load();
        });
      }

      window.KTApp.unblockPage();
      this.filter.click();
    });
  }

  bindChangeDateFilter(){
    $('#kt_dashboard_datepicker_custom').on('change', function(e) {
      this.datatable.setDataSourceParam('date', e.currentTarget.value);
      this.datatable.load();
    }.bind(this));
  }

  datatableExtensions(){
    return {
      checkbox: true
    };
  }

  datatableColumns(){
    return [
      {
        field: 'id',
        title: '#',
        sortable: false,
        width: 40,
        selector: true,
        textAlign: 'center',
      },
      // {
        // field: 'index',
        // title: '#',
        // sortable: false,
        // width: 40,
        // type: 'number',
        // selector: false,
        // textAlign: 'left',
        // template: function(data) {
          // return `<span class="font-weight-bolder">${data.index}</span>`;
        // }
      // },
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
        width: 120,
        template: function(data) {
          return `
            <div class="font-weight-bolder position-relative">
              <span
                class="label label-${data.status_label_html_class} mr-1" style="vertical-align:middle;"
                title="Status: ${data.status_translate}"
                data-controller="base--tooltip"
              >
              </span>
              <span>${data.number_evidence}</span>
            </div>
          `;
        }
      },
      {
        field: 'source',
        title: 'Sumber',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.source}</span>`;
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
          let res = `
            <a href="${data.show_path}" class="btn btn-sm btn-clean btn-icon">
              <i class="la la-eye text-primary"></i>
            </a>
          `
          if(data.approver){
            return res;
          }

          if(data.is_super_admin){
            res = `${res}
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
            return res;
          }

          if(data.is_owner){
            if(data.status === 'accepted'){
              res = `${res}
              <a href="javascript:void(0);" class="btn btn-sm btn-clean btn-icon"
                data-toggle="modal"
                data-target="#Edit"
                data-controller="admin--edit"
                data-action="click->admin--edit#handleClick"
                data-admin--edit-path="${data.edit_path}"
              >
                <i class="la la-edit text-warning"></i>
              </a>
              `;
            } else {
              res = `${res}
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
            }
          }
          return res;
        },
      }
    ]
  }
}
