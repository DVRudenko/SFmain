/**
 * Created by pgolyakov on 2019-07-25.
 */
public class PD_ContactController extends PD_RecordController {

    public Contact obj {get; private set;}

    public PD_ContactController(ApexPages.StandardController stdController) {
        super(stdController);
    }

    protected override void setObj() {
        obj = (Contact)stdController.getRecord();
    }

    public override SObject getObj() {
        return (Contact)obj;
    }

    protected override void setOwner() {
        if (obj.Id == null) {
            obj.Owner = [select Id, Name from User where Id=:UserInfo.getUserId()];
        }
    }

    public virtual PageReference saveMe2() {
        SObject obj = getObj();
        try {
            if (obj.Id == null) {
                insert obj;
            } else {
                update obj;
            }
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }

        return new PageReference('/' + obj.Id);
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