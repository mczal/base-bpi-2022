import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.quickUserElement = document.querySelector('#kt_quick_user');
    this.quickUserClose = document.querySelector('#kt_quick_user_close');
  }

  connect(){
    this.quickUserClose.addEventListener('click', (e) => {
      this.hidePanel();
    });
  }

  handleClick(e){
    if(this.quickUserElement.classList.contains('offcanvas-on')){
      this.hidePanel();
      return;
    }
    this.showPanel();
    this.bindClickOutside();
  }

  bindClickOutside(){
    const overlay = this.getOverlay();
    overlay.addEventListener('click', () => {
      this.hidePanel();
    });
  }

  showPanel(){
    this.quickUserElement.classList.add('offcanvas-on');
    this.quickUserElement.insertAdjacentHTML('afterend', `
      <div id="js-offcanvas-overlay" class="offcanvas-overlay"></div>
    `);
  }
  hidePanel(){
    this.quickUserElement.classList.remove('offcanvas-on');
    const overlay = document.querySelector('#js-offcanvas-overlay');
    if(overlay){
      window.Util.removeElement(overlay);
    }
  }

  getOverlay(){
    return document.querySelector('#js-offcanvas-overlay');
  }
}

