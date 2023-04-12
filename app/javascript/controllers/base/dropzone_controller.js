import { Controller } from 'stimulus';
import { DirectUpload } from "@rails/activestorage";
import { getMetaValue, toArray, findElement, removeElement, insertAfter, insertBefore } from "./lib/helpers";

export default class extends Controller {
  static targets = [ "input" ]

  connect() {
    this.dropzone = createDropZone(this)
    this.hideFileInput()
    this.bindEvents()
  }

  // Private
  hideFileInput() {
    this.inputTarget.disabled = true
    this.inputTarget.style.display = "none"
  }

  bindEvents() {
    this.dropzone.on("addedfile", (file) => {
      setTimeout(() => { file.accepted && createDirectUploadController(this, file).start() }, 500)
    })

    this.dropzone.on("removedfile", (file) => {
      file.controller && removeElement(file.controller.hiddenInput)
    })

    this.dropzone.on("canceled", (file) => {
      file.controller && file.controller.xhr.abort()
    })

    this.dropzone.on("processing", (file) => {
      if(this.submitButton){
        this.submitButton.disabled = true
      }
    })

    this.dropzone.on("queuecomplete", (file) => {
      if(this.submitButton){
        this.submitButton.disabled = false
      }

      const event = new Event('dropzone:queuecomplete');
      this.element.dispatchEvent(event);
    })

    this.dropzone.on('error', (file,error) => {
      window.setTimeout(() => {
        this.dropzone.removeFile(file);
        window.alert(error);
      }, 500);
    })

    this.dropzone.on('maxfilesexceeded', (file) => {
      window.setTimeout(() => {
        this.dropzone.removeFile(file);
        window.alert('[Max Files Exceeded = 1] Maksimum file hanya 1, hapus terlebih dahulu file yang sudah terupload (dengan klik tombol silang merah), lalu pilih file kembali');
      }, 500);
    })
  }

  get headers() { return { "X-CSRF-Token": getMetaValue("csrf-token") } }

  get url() { return this.inputTarget.getAttribute("data-direct-upload-url") }

  get dictRemoveFile() { return this.data.get("dictRemoveFile") }

  get maxFiles() { return this.data.get("maxFiles") || 1 }

  get maxFileSize() { return this.data.get("maxFileSize") || 256 }

  get acceptedFiles() { return this.data.get("acceptedFiles") }

  get addRemoveLinks() { return this.data.get("addRemoveLinks") || true }

  get form() { return this.element.closest("form") }

  get submitButton() { return findElement(this.form, this.data.get('submitButtonSelector')) }
}

class DirectUploadController {
  constructor(source, file) {
    this.directUpload = createDirectUpload(file, source.url, this)
    this.source = source
    this.file = file
  }

  start() {
    this.file.controller = this
    this.hiddenInput = this.createHiddenInput()
    this.directUpload.create((error, attributes) => {
      if (error) {
        removeElement(this.hiddenInput)
        this.emitDropzoneError(error)
      } else {
        this.hiddenInput.value = attributes.signed_id
        this.emitDropzoneSuccess()
        if(this.source.data.get('onceUploadAutoSubmitForm')){
          window.KTApp.blockPage();
          this.source.form.submit();
        }
      }
    })
  }

// Private
  createHiddenInput() {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = this.source.inputTarget.name
    insertBefore(input, this.source.inputTarget)
    return input
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr)
    this.emitDropzoneUploading()
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr
    this.xhr.upload.addEventListener("progress", event => this.uploadRequestDidProgress(event))
  }

  uploadRequestDidProgress(event) {
    const element = this.source.element
    const progress = event.loaded / event.total * 100
    findElement(this.file.previewTemplate, ".dz-upload").style.width = `${progress}%`
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING
    this.source.dropzone.emit("processing", this.file)
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR
    this.source.dropzone.emit("error", this.file, error)
    this.source.dropzone.emit("complete", this.file)
  }

  emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS
    this.source.dropzone.emit("success", this.file)
    this.source.dropzone.emit("complete", this.file)
  }
}

// Top level...
function createDirectUploadController(source, file) {
  return new DirectUploadController(source, file)
}

function createDirectUpload(file, url, controller) {
  return new DirectUpload(file, url, controller)
}

function dropZoneOptions(controller){
  const options = {
    url: controller.url,
    headers: controller.headers,
    maxFiles: controller.maxFiles,
    maxFilesize: controller.maxFileSize,
    acceptedFiles: controller.acceptedFiles,
    addRemoveLinks: !!controller.addRemoveLinks,
    autoQueue: false,
  };
  if(controller.dictRemoveFile){
    options['dictRemoveFile'] = controller.dictRemoveFile;
  }

  return options;
}

function createDropZone(controller) {
  return $(controller.element)
    .dropzone(dropZoneOptions(controller))
    .get(0)
    .dropzone;
}
