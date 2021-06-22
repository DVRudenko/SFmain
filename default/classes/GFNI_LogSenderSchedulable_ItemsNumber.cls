/**
 * Created by Nikita.Mikhailov on 25.02.2019.
 */

public with sharing class GFNI_LogSenderSchedulable_ItemsNumber {
    public Integer numberOfSuccessfulItems { get; set; }

    //public Integer numberOfFailedItems { get; set; }

    public GFNI_LogSenderSchedulable_ItemsNumber() {
        this.numberOfSuccessfulItems = 0;
        //this.numberOfFailedItems = 0;
    }
}