import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['display', 'input'];

  initialize(){
  }

  connect(){
    this.inputTarget.addEventListener('keydown', this.handleInput.bind(this));
  }

  handleInput(){
    this.displayTarget.innerHTML = this.formatedInput;
  }

  get formatedInput(){
    const res = [];
    const npwp = this.inputTarget.value;

    res.push(`${npwp[0] || '_'}${npwp[1] || '_'}`);
    res.push(`${npwp[2] || '_'}${npwp[3] || '_'}${npwp[4] || '_'}`);
    res.push(`${npwp[5] || '_'}${npwp[6] || '_'}${npwp[7] || '_'}`);
    res.push(`${npwp[8] || '_'}-${npwp[9] || '_'}${npwp[10] || '_'}${npwp[11] || '_'}`);
    res.push(`${npwp[12] || '_'}${npwp[13] || '_'}${npwp[14] || '_'}`);

    return res.join('.');
  }
}

