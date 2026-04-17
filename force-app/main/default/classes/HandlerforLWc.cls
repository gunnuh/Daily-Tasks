public class HandlerforLWc {
    @AuraEnabled(cacheable=true)
    public static List<Account> Accountrec(){
        return [Select Id,Name from Account limit 5];

    }
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> RelatedOpportunities(Id accountId){
        return [SELECT ACCOUNTID,NAME,STAGENAME,AMOUNT FROM  OPPORTUNITY  WHERE ACCOUNTID  =:accountId];
    }
    @AuraEnabled
    public static void updateOpportunities(List<Opportunity> oppList){
        update oppList;
    }

 
}