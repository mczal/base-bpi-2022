import { Controller } from 'stimulus';

export default class extends Controller {
  initialize(){
    this.label = this.element.previousElementSibling;
  }

  connect(){
    this.setup();
  }

  setup(){
    $(this.element).datepicker({
      todayHighlight: true,
      autoclose: true,
      format: 'mm-yyyy',
      startView: "months",
      minViewMode: "months"
    });

    $(this.element).on('change', (e) => {
      if(this.data.get('refreshOnChange') && this.data.get('refreshOnChange') === '1'){
        window.location.search = `date=${this.element.value}`;
      }

      const date = moment(this.element.value, 'MM-YYYY');
      this.label.innerHTML = date.format('MMMM YYYY');
    })
  }
}
