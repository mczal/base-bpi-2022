import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect(){
    let title = this.element.dataset.sweetAlertTitle;
    let icon = this.element.dataset.sweetAlertIcon;
    let confirmButtonText = this.element.dataset.sweetAlertConfirmButtonText;
    let cancelButtonText = this.element.dataset.sweetAlertCancelButtonText;

    $(this.element).click(function (e) {
      let modalElement = document.querySelector('#add-invoice');
      let invoicePrice = parseFloat(modalElement.querySelector('input[name="invoice[price]"]').value.replaceAll('.', '').replace(',', '.'));

      let taxIncludeElement = modalElement.querySelectorAll('input[name="invoice[tax_include]"]');

      let selectedPphElement = modalElement.querySelector('select[name="invoice[tax_rate_id]"]');
      let percentage = '';
      if (selectedPphElement.value != ''){
        let selectedPphValue = selectedPphElement.options[selectedPphElement.selectedIndex].text;
        let getValueInsideParentheses = /\(([^)]+)\)/;
        let pphPercentage = getValueInsideParentheses.exec(selectedPphValue)[1].replace(',','.');
        percentage = parseFloat(pphPercentage) * 1/100;
      } else {
        percentage = 0;
      }

      let taxIncludeValue = '';
      for(let i=0; i<taxIncludeElement.length; i++){
        if(taxIncludeElement[i].checked){
          taxIncludeValue = taxIncludeElement[i].value;
        }
      }

      let nominalDpp = 0.00;
      if (taxIncludeValue == 'include') {
        nominalDpp = Math.round((invoicePrice/1.1));
      } else {
        nominalDpp = Math.round(invoicePrice);
      }

      let ppn = 0.00
      let pph = 0.00

      ppn = Math.round((0.1 * nominalDpp));
      pph = Math.floor((percentage * nominalDpp));

      let detailInvoiceValueHtml = `
        <table class="table table-borderless table-vertical-center">
          <tbody>
            <tr>
              <td class="px-3 py-2 text-left">Nilai Invoice</td>
              <td class="px-3 py-2 text-right">Rp. ${ window.Util.addThousandSeparator(invoicePrice.toFixed(2).replace(".",","))}</td>
            </tr>
            <tr>
              <td class="px-3 py-2 text-left">Nominal DPP</td>
              <td class="px-3 py-2 text-right">Rp. ${ window.Util.addThousandSeparator(nominalDpp.toFixed(2).replace(".",","))}</td>
            </tr>
            <tr>
              <td class="px-3 py-2 text-left">PPn</td>
              <td class="px-3 py-2 text-right">Rp. ${ window.Util.addThousandSeparator(ppn.toFixed(2).replace(".",","))}</td>
            </tr>
            <tr>
              <td class="px-3 py-2 text-left">PPh</td>
              <td class="px-3 py-2 text-right">Rp. ${ window.Util.addThousandSeparator(pph.toFixed(2).replace(".",","))}</td>
            </tr>
          </tbody>
        </table>
      `;
      Swal.fire({
        title: title,
        icon: icon,
        html: detailInvoiceValueHtml,
        allowOutsideClick: false,
        buttonsStyling: false,
        confirmButtonText: `<i class='la la-check'></i> ${confirmButtonText}`,
        showCancelButton: true,
        cancelButtonText: `<i class='la la-times'></i> ${cancelButtonText}`,
        customClass: {
          confirmButton: "btn btn-success",
          cancelButton: "btn btn-danger"
        }
      }).then((result) => {
        if (result.isConfirmed) {
          Swal.fire('Data Valid', '', 'success');
          document.querySelector('.js-submit-button').disabled = false;
        }
      });
    });
  }
}
