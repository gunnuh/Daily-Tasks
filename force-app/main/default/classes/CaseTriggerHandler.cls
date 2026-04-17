public class CaseTriggerHandler {
    public static void handle(List<Case> caselist, Map<Id, Case> oldMap){
        List<Task> tasklist = new List<Task>();
        List<Account> acclist = new List<Account>();
        for(Case c: caselist){
            if(c.Status != oldMap.get(c.Id).Status){
                for(Task t : [select Id from Task where WhatId = :c.Id]){
                    t.Status = c.Status;
                    tasklist.add(t);
                }
                if(c.AccountId != NULL){
                    acclist.add(new Account(Id = c.AccountId, Description='acdefgh'));
                }
            }
        }
        if(!tasklist.isEmpty()) update tasklist;
        if(!acclist.isEmpty()) update acclist;
    }
}