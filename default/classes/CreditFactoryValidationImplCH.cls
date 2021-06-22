public class CreditFactoryValidationImplCH extends CreditFactoryValidationImpl {

    /*******************************************************************************
    *  Summary         : return Name of Credit System
    *  Created         : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : name of credit system
    ******************************************************************************/
    protected override String returnCreditSystemName() {
        return 'Crediconnect';
    }


    /*******************************************************************************
    *  Summary         : Check Attachment with name "BDD"
    *  CreatedDate     : 26/11/2020 by Ivan Kulinkovich
    *  Parameters      : -
    *  Returns         : validation result
    ******************************************************************************/
    protected override CreditFactoryValidationItem validateSepaAttachment() {
        CreditFactoryValidationItem validationItem = new CreditFactoryValidationItem();
        Boolean isSEPAAttachmentExist = false;
        Boolean isSEPAFileExist = false;
    	if (this.internalCFCompany.paymentMethod == 'Lastschrift' && this.internalCFCompany.sepaRequestApproved != true && this.internalCFCompany.directDebitFormAvailable == true) {
            if (this.internalCFCompany.attachments != null) {
                for (CreditFactoryCompany.CreditFactoryAttachment attachment : this.internalCFCompany.attachments) {
                    if (attachment.name.containsIgnoreCase('BDD')) {
                        isSEPAAttachmentExist = true;
                        break;
                    }
                }
            }
            if (this.internalCFCompany.files != null) {
                for (CreditFactoryCompany.CreditFactoryFile file : this.internalCFCompany.files) {
                    if (file.title.containsIgnoreCase('BDD')) {
                        isSEPAFileExist = true;
                        break;
                    }
               }
            }

            if (isSEPAAttachmentExist || isSEPAFileExist) {
                validationItem.passed = true;
            }
            else {
                validationItem.passed = false;
                validationItem.description = 'Please attach SEPA form to the Opportunity to launch Credit Factory.';
            }
    	}
        else {
            validationItem.passed = true;
        }

        return validationItem;
    }
}