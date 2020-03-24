import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

export default class ChainableJsonView extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api jsonField;

    fieldsFormatted = [];

    @wire(getRecord, { recordId: "$recordId", fields: "$fieldsFormatted" })
    wiredChainableLink({ error, data }) {
        if (data && this.recordId) {
            this.record = data;
            this.error = undefined;

            this.jsonText = this.record.fields[this.jsonField].value;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    @api
    jsonText;

    connectedCallback() {
        this.fieldsFormatted.push(this.objectApiName + ".Id");
        this.fieldsFormatted.push(this.objectApiName + "." + this.jsonField);
    }
}
