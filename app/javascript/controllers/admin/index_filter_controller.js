import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['panel','filterTriggerer','numberEvidence','code','location','description'];

  initialize(){
  }

  connect(){
    this.panelTarget.addEventListener('click',(e) => {
      e.stopPropagation();
    });
  }

  toggle(){
    if(this.panelTarget.classList.contains('d-none')){
      this.panelTarget.classList.remove('d-none');
      this.panelTarget.classList.add('d-flex');
      return;
    }
    this.panelTarget.classList.add('d-none');
    this.panelTarget.classList.remove('d-flex');
  }

  reset(){
    this.numberEvidenceTarget.value = '';
    this.descriptionTarget.value = '';
    this.locationTargets.forEach((x) => {
      if(!x.value){
        x.checked = true;
      }
    });
    $(this.codeTarget).val('').trigger('change');

    this.filterTriggererTarget.click();
  }
}
