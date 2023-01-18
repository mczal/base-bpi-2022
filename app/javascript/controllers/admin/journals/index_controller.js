import DatatablesController from '../../datatables_controller';

export default class extends DatatablesController {
  initialize(){
    super.initialize();
    this.filter = document.querySelector('[data-controller="admin--index-filter"]');
    this.filterTriggerer = this.filter.querySelector('[data-admin--index-filter-target="filterTriggerer"]');
  }

  connect(){
    super.connect();
    this.bindDateChange();
    this.bindFilter();
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

  bindDateChange(){
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
        autoHide: false,
        overflow: 'visible',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.index}</span>`;
        }
      },
      {
        field: 'date',
        title: 'Tanggal',
        width: 100,
        overflow: 'visible',
        autoHide: false,
        template: function(data) {
          if(!data.date){
            return '';
          }
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
        autoHide: false,
        overflow: 'visible',
        sortable: false,
        template: function(data) {
          if(!data.number_evidence){
            return '';
          }
          return `
            <span class="font-weight-bolder">
              ${data.number_evidence}
            </span>
            <a class="ml-1" href="${data.source_path}" title="Sumber" data-controller="base--tooltip" target="_blank">
              <i class="fas fa-external-link-alt font-size-sm"></i>
            </a>
          `;
        }
      },
      {
        field: 'code',
        title: 'Akun',
        autoHide: false,
        overflow: 'visible',
        sortable: false,
        width: '150',
        template: function(data) {
          return `
            <div>
              <span data-controller="base--popover" data-base--popover-html="1" data-base--popover-trigger="hover" data-content="<div><b>${data.account_category_description}</b></div><div>${data.account_category_range}</div>" data-title="Kategori" class="svg-icon svg-icon-light-dark" style="cursor:pointer;">
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="24px" height="24px" viewBox="0 0 24 24" version="1.1">
                    <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                        <rect x="0" y="0" width="24" height="24"/>
                        <circle fill="#000000" opacity="0.3" cx="12" cy="12" r="10"/>
                        <rect fill="#000000" x="11" y="10" width="2" height="7" rx="1"/>
                        <rect fill="#000000" x="11" y="7" width="2" height="2" rx="1"/>
                    </g>
                </svg>
              </span>
              <b>${data.code}</b>
            </div>
            <div>
              ${data.account_name}
            </div>
          `;
        }
      },
      {
        field: 'location',
        title: 'Lokasi',
        autoHide: false,
        overflow: 'visible',
        textAlign: 'center',
        template: function(data) {
          return `${data.location}`;
        }
      },
      {
        field: 'description',
        title: 'Deskripsi',
        autoHide: false,
        overflow: 'visible',
        sortable: false,
        width: '350',
        template: function(data) {
          return `${data.description}`;
        }
      },
      {
        field: 'debit_idr',
        title: 'Debit (IDR)',
        autoHide: false,
        overflow: 'visible',
        sortable: false,
        template: function(data) {
          return `<span class="font-weight-bolder">${data.debit_idr}</span>`;
        }
      },
      {
        field: 'credit_idr',
        title: 'Kredit (IDR)',
        autoHide: false,
        sortable: false,
        overflow: 'visible',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.credit_idr}</span>`;
        }
      },
      {
        field: 'rates_options',
        title: 'Kurs',
        autoHide: false,
        sortable: false,
        sortable: false,
        overflow: 'visible',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.rates_value}</span>`;
        }
      },
      {
        field: 'debit_usd',
        title: 'Debit (USD)',
        autoHide: false,
        sortable: false,
        overflow: 'visible',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.debit_usd}</span>`;
        }
      },
      {
        field: 'credit_usd',
        title: 'Kredit (USD)',
        autoHide: false,
        sortable: false,
        overflow: 'visible',
        template: function(data) {
          return `<span class="font-weight-bolder">${data.credit_usd}</span>`;
        }
      },
    ]
  }
}
