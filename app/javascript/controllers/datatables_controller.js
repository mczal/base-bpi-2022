import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.dataPath = this.data.get('dataPath');
  }

  connect(){
    this.datatable = $(this.element)
      .KTDatatable(this.args());
  }

  args(){
    return {
      data: this.datatableData(),
      layout: this.datatableLayout(),
      sortable: this.datatableSortable(),
      pagination: this.datatablePagination(),
      search: this.datatableSearch(),
      columns: this.datatableColumns(),
      extensions: this.datatableExtensions(),
    }
  }

  datatableData(){
    return {
      type: 'remote',
      saveState: false,
        source: {
          read: {
            url: this.dataPath,
            headers: {
              'X-CSRF-Token': window.Util.getCsrfToken()
            }
          },
        },
        pageSize: 10, // display 10 records per page
        serverPaging: true,
        serverFiltering: true,
        serverSorting: true,
    };
  }

  datatableLayout(){
    return {
      scroll: false, // enable/disable datatable scroll both horizontal and vertical when needed.
      footer: false, // display/hide footer
    }
  }

  datatableSortable(){
    return true;
  }

  datatablePagination(){
    return true;
  }

  datatableSearch(){
    return {
      input: $('#kt_datatable_search_query'),
      delay: 400,
      key: 'search'
    }
  }

  datatableExtensions(){
    return {};
  }
}
