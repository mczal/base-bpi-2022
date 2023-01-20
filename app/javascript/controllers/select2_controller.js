import { Controller } from 'stimulus';

export default class extends Controller {
  connect(){
    $(this.element).select2(this.options);
  }

  get options() {
    const result = {
      matcher: function (params, data) {
        let original_matcher = $.fn.select2.defaults.defaults.matcher;
        let result = original_matcher(params, data);
        if (
          result &&
          data.children &&
          result.children &&
          data.children.length != result.children.length &&
          data.text.toLowerCase().includes(params.term)
        ) {
          result.children = data.children;
        }
        return result;
      },
      placeholder: this.placeholder,
    }
    if (this.data.get('tags')) {
      result['tags'] = true
    }

    return result;
  }

  get placeholder(){
    this._placeholder = '== Pilih =='
    if(this.element.dataset.placeholder){
      this._placeholder = this.element.dataset.placeholder;
    }

    return this._placeholder;
  }
}
