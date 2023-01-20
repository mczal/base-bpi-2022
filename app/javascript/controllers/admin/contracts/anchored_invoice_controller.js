import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect(){
    if(!window.location.hash){
      return;
    }

    const selector = `#I${window.location.hash.replace(/-/g,'').replace(/#/,'').toUpperCase()}`;
    const anchoredElement = document.querySelector(selector);
    anchoredElement.classList.add('anchored');
  }
}
