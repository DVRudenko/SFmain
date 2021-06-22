import { LightningElement, api } from "lwc";

export default class LoadingContent extends LightningElement {
    @api text;
    @api hideFigure;
}
