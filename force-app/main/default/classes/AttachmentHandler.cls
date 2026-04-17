public class AttachmentHandler {

    public static void method(){
        try{
            List<Attachment> accAttachments = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN (SELECT Id FROM Account)];
            Map<Id, List<Contact>> acmap = new Map<Id, List<Contact>>();
            for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId != NULL]){
                if(!acmap.containsKey(con.AccountId)){
                    acmap.put(con.AccountId, new List<Contact>());
                }
                acmap.get(con.AccountId).add(con);
            }
            List<Attachment> newattach = new List<Attachment>();
            for(Attachment a : accAttachments){
                if(acmap.containsKey(a.ParentId)){
                    for(Contact c : acmap.get(a.ParentId)){
                        Attachment result = new Attachment();
                        result.Name = a.Name;
                        result.Body = a.Body;
                        result.ParentId = c.Id;
                        newattach.add(result);
                    }
                }
            }

            if(!newattach.isEmpty()){
                insert newattach;
            }

            System.debug('Task done');
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}