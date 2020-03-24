import { LightningElement, api } from "lwc";

export default class ChainableLinkJsonViewLWC extends LightningElement {
    @api recordId;

    reactJsonViewProps = { name: "Action Data", displayDataTypes: false };
}
