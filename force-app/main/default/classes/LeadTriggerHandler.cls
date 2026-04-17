public class LeadTriggerHandler {
    public static void createtask(List<Lead> leadList){
        Set<Id> leadids = new Set<Id>();
        for(Lead l : leadlist){
            if(l.Status == 'Closed - Converted') leadids.add(l.Id);
        }
        List<Task> tasklist = new List<Task>();
        for(Id i: leadids){
            Task t = new Task();
            t.WhoId = i;
            t.OwnerId = UserInfo.getUserId();
            t.Status = 'Not Started';
            t.Subject = 'This task is generated';
            t.Priority = 'Normal';
            tasklist.add(t);
        }
        if(!tasklist.isEmpty()){
            insert tasklist;
        }
    }
}