import { Controller } from 'stimulus';

export default class extends Controller {
  connect(){
    if ($('#kt_dashboard_daterangepicker_custom').length == 0) {
        return;
    }

    this.initDatePicker();

    if(this.data.get('preventDefault')){
      return;
    }
    $('#kt_dashboard_daterangepicker_custom').on('apply.daterangepicker', function(ev, picker) {
      this.urlChange(picker);
    }.bind(this));
  }

  initDatePicker(){
    var picker = $('#kt_dashboard_daterangepicker_custom');

    var start = picker.data("startDate");
    var end = picker.data("endDate");

    if(start == ""){
      start = moment().startOf('year');
    }else{
      start = moment(picker.data("startDate"), "DD/MM/YYYY");
    }

    if(end == ""){
      end = moment();
    }else{
      end = moment(picker.data("endDate"), "DD/MM/YYYY");
    }

    function cb(start, end, label) {
      var title = '';
      var range = '';

      range = start.format('MMM D YYYY') + ' - ' + end.format('MMM D YYYY');

      $('#kt_dashboard_daterangepicker_date_custom').html(range);
      $('#kt_dashboard_daterangepicker_title_custom').html(title);
    }

    picker.daterangepicker({
      direction: KTUtil.isRTL(),
      startDate: start,
      endDate: end,
      opens: 'left',
      applyClass: 'btn-primary',
      cancelClass: 'btn-light-primary',
      ranges: {
          'Last 7 days': [moment().subtract(6, 'days'), moment()],
          'Last 30 days': [moment().subtract(29, 'days'), moment()],
          'This month': [moment().startOf('month'), moment().endOf('month')],
          'Last month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
      }
    }, cb);

    cb(start, end, '');
  }

  urlChange(datepicker){
    var startDate = datepicker.startDate.format("D/M/Y")
    var endDate  = datepicker.endDate.format("D/M/Y")

    var queryParams = new URLSearchParams(window.location.search);
    queryParams.set("start_date", startDate);
    queryParams.set("end_date", endDate);
    history.pushState(null, null, "?"+queryParams.toString());
    window.location.reload()
  }
}
