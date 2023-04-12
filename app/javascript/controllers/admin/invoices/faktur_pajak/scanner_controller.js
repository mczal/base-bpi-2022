import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  initialize(){
    this.path = this.data.get('path');
    this.dropzoneInputPng = this.element.querySelector('.js-dropzone-fp-png');
    this.dropzoneInputPdf = this.element.querySelector('.js-dropzone-fp-pdf');

    this.inputContainer = this.element.querySelector('.js-input-container');
    this.resultContainer = this.element.querySelector('.js-result');
  }

  connect(){
    this.dropzoneInputPng.addEventListener('dropzone:queuecomplete', this.handleQueuecompletePng.bind(this));
    this.dropzoneInputPdf.addEventListener('dropzone:queuecomplete', this.handleQueuecompletePdf.bind(this));
  }

  refresh(){
    this.resultContainer.innerHTML = '';
    this.inputContainer.classList.remove('d-none');
  }

  handleQueuecompletePng(){
    const path = this.path
      .replace(/xxx/, 'png')
      .replace(/yyy/, this.inputPng.value);
    window.KTApp.blockPage();
    window.Ajax.post(path, this.ajaxOptions)
  }
  handleQueuecompletePdf(){
    const path = this.path
      .replace(/xxx/, 'pdf')
      .replace(/yyy/, this.inputPdf.value);
    window.KTApp.blockPage();
    window.Ajax.post(path, this.ajaxOptions)
  }

  handleSuccess(responseText){
    const parsedResponse = JSON.parse(responseText);
    window.Flash.show('success', parsedResponse.message);

    this.inputContainer.classList.add('d-none');
    this.resultContainer.innerHTML = parsedResponse.html;
  }
  handleFail(responseText){
    const parsedResponse = JSON.parse(responseText);
    console.error('[ERROR]', responseText);
    window.Flash.show('danger', parsedResponse.message);
  }
  handleDone(){
    window.KTApp.unblockPage();
  }

  get ajaxOptions(){
    return {
      onDone: this.handleDone.bind(this),
      onFail: this.handleFail.bind(this),
      onSuccess: this.handleSuccess.bind(this),
      headers: [
        {
          key: 'X-CSRF-Token',
          value: window.Util.getCsrfToken()
        },
        {
          key: 'Content-Type',
          value: 'application/json'
        },
      ]
    };
  }

  get inputPng(){
    return this.element.querySelector('input[type="hidden"][name="faktur_pajak[png]"]');
  }
  get inputPdf(){
    return this.element.querySelector('input[type="hidden"][name="faktur_pajak[pdf]"]');
  }
}
