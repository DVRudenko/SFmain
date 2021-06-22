public class ServiceConsoleHelpRuCtrl {

    private static final String entryStringPoint = 'force.com/';
    private Integer tabNumber = 1;

    public String sourceText { get; set; }
    public String tabLink { get; set; }
    public String tabName { get; set; }

    /*******************************************************************************
    *  Name            : generateNewTab
    *  Summary         : Determine targetLink and targetName for new Tab
    *  CreatedDate     : 28/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void prepareTabParams(){
        Integer index = sourceText.indexOf(entryStringPoint);// Getting index of "instance name" in URL (If sourceText is link).
        if(index == -1){
            tabLink = sourceText;
        } else {
            tabLink = sourceText.substring(index + entryStringPoint.length());
        }
        tabName = getTabName(tabLink);
    }

    /*******************************************************************************
    *  Name            : getTabName
    *  Summary         : Try to find Tab.Name || Tab.Name - Name of sObject record with ID = targetLink
    *  CreatedDate     : 28/01/2019
    *  Parameters      : String targetLink
    *  Returns         : String (tabName)
    ******************************************************************************/
    private String getTabName(String tabLink){
        String tabName = 'Вкладка';
        if(tabLink != '') {
            try{
                Id sObjectId = Id.valueOf(tabLink);
                String objectName = '';
                objectName = sObjectId.getSobjectType().getDescribe().name;
                if(objectName != ''){
                    Database.QueryLocator sObjectList = DataBase.getQueryLocator('SELECT NAME FROM '+objectName+' WHERE ID=:tabLink LIMIT 1');
                    Database.QueryLocatorIterator iterator = sObjectList.iterator();
                    if(iterator.hasNext()){
                        sObject newSObject = (sObject)iterator.next();
                        tabName = (String)newSObject.get('Name');
                    }
                }
            }catch(Exception e){
                
            }
            if (tabName == 'Вкладка'){
                tabName += ' ' + String.valueOf(tabNumber);
                tabNumber = tabNumber + 1;
            }
        }
        return tabName;
    }

}