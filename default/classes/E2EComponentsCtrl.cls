public class E2EComponentsCtrl {
    
    public String listValueSplitString {get; set;}
    public String splitRegex {get; set;}

    /*******************************************************************************
    *  Name            : init()
    *  Summary         : data initialization
    *  CreatedDate     : 10/07/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
        try {

        } catch (Exception e) {

        }
    }

    public List<String> GetSplits()
    {
        List<String> listSuppliers = new List<String>();
        for (String item : listValueSplitString.split(splitRegex)) {
            listSuppliers.add(item.split('@')[0]);
        }
        return listSuppliers;
    }

    public String GetFirstListValue()
    {
        return listValueSplitString.split(splitRegex)[0].split('@')[0];
    }

}