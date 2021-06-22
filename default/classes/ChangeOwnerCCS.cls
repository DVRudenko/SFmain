global without sharing class ChangeOwnerCCS {
       webservice static void changeOwner(String cid, String us){
             Contact cont = [SELECT Owner.Id FROM Contact where Id = :cid];
             User use = [SELECT Id FROM User where Id = :us];
             cont.OwnerId = use.Id;
             update cont;
        }
  }