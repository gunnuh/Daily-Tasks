import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class MyModal extends LightningModal {
  @api recordId;
  handleSave(){
    this.template.querySelector('lightning-record-edit-form').submit();
  }
  handleSuccess(){
    this.close('Saved');
  }
  handleCancel() {
    this.close("Cancel");
  }
}