import BasePrechat from 'lightningsnapin/basePrechat';
import { api, track } from 'lwc';
// import startChatLabel from '@salesforce/label/c.StartChat';

export default class Prechat extends BasePrechat {
    @api prechatFields;
    @track fields;
    @track namelist;
    @api ico;
    @api companyName;
    nameToLabelMap = {
        'FirstName' : 'Jméno',
        'LastName' : 'Příjmení',
    }
    startChatLabel = 'Chat';

    /**
     * Set the button label and prepare the prechat fields to be shown in the form.
     */
    connectedCallback() {
        this.fields = this.prechatFields.map(field => {
            let preChatField = {
                label : this.nameToLabelMap[field.name],
                name : field.name,
                value : field.value,
                required : field.required,
                maxLength : field.maxLength
            };

            // const { label, name, value, required, maxLength } = changedField;

            // return { label, value, name, required, maxLength };
            return preChatField
        });
        this.namelist = this.fields.map(field => field.name);
        console.log('namelist ===', this.namelist)
        console.log('fields ===', this.fields)
        console.log('prechatFields ===', this.prechatFields)
    }

    /**
     * Focus on the first input after this component renders.
     */
    // renderedCallback() {
    //     this.template.querySelector("lightning-input").focus();
    // }

    /**
     * On clicking the 'Start Chatting' button, send a chat request.
     */
    handleStartChat() {
        this.template.querySelectorAll(".contact-name-fields").forEach(input => {

            this.fields[this.namelist.indexOf(input.name)].value = input.value;
        });
        if (this.validateFields(this.fields).valid) {
            console.log('this.ico ===', this.ico);
            var event = new CustomEvent(
                "setCustomField",
                {
                    detail: {
                        callback: this.startChat.bind(this, this.fields),
                        icoValue: this.ico,
                        firstName: this.fields[0].value,
                        lastName: this.fields[1].value,
                        companyName: this.companyName
                    }
                }
            );
            // Dispatch the event.
            document.dispatchEvent(event);
        } else {
            console.log('=======', this.validateFields(this.fields));
            // Error handling if fields do not pass validation.
        }
    }


    handleChangeInputValue(event){
        this[event.target.name] = event.target.value;
    }
}