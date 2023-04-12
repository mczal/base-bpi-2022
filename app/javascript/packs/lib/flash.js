export default class Flash {
  static show(type, message){
    const html = this.html(type, message);
    const currentFlash = document.querySelector('#js-Flash');
    if(currentFlash){
      window.Util.removeElement(currentFlash);
    }

    document.body.insertAdjacentHTML('afterbegin', this.html(type, message));
  }

  static html(type, message){
    return `
      <div id="js-Flash" style="z-index:10000;position:fixed;top:0;left:0;width:100%;" class="alert alert-custom alert-notice alert-light-${type} fade show" role="alert">
        <div class="alert-icon"><i class="flaticon-warning"></i></div>
        <div class="alert-text">${message}</div>
        <div class="alert-close">
          <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true"><i class="ki ki-close"></i></span>
          </button>
        </div>
      </div>
    `;
  }
}
