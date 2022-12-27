import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.trigger = this.data.get('trigger') || 'click';
    this.html = !!this.data.get('html');
  }

  connect(){
    $(this.element).popover({
      trigger: this.trigger,
      html: this.html
    });
  }
}

