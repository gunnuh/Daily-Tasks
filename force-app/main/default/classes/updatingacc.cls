public class updatingacc {
    public static void updation(){
        Set<Id> accIds = new Set<id>();
        for(Contact c:[select id, AccountId from contact where AccountId!=null]){
            accIds.add(c.AccountId);
        }
        List<Account> acclist = [select id, Rating, Active__c from Account where Id in:accIds];
        for(Account a: acclist){
            a.Rating = 'Hot';
            a.Active__c = 'Yes';
        }
        if(!acclist.isEmpty()){
            update acclist;
        }
    }
}