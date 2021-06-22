public with sharing class PD_LeadController extends PD_RecordController {

    public Lead obj {get; private set;}
    
    public PD_LeadController (ApexPages.StandardController stdController) {
        super(stdController);
    }

    protected override void setObj() {
        obj = (Lead)stdController.getRecord();
    }

    public override SObject getObj() {
        return (Lead)obj;
    }

    protected override void setOwner() {

    }

    public SelectOption[] getSalutations() {
        
        SelectOption[] sos = new SelectOption[]{};
        sos.add(new SelectOption('', '----'));
        
        for (Schema.PicklistEntry plv:Contact.Salutation.getDescribe().getPickListValues()){
            sos.add(new SelectOption(plv.getValue(), plv.getLabel()));
        }
        
        return sos;
    }
}