public class OpportunityHandler {
    public static void updation(List<Opportunity> oppList) {
        Set<Id> accids = new Set<Id>();
        for(Opportunity o : oppList){
            if(o.AccountId!=NULL) accids.add(o.Id);
        }
        List<Account>acclist = [select Id from Account where Id IN :accids];
        for(Account acc : acclist){
            List<Opportunity> olist = [select Amount from Opportunity Where AccountId = :acc.Id];
            Decimal total = 0;
            Integer n = olist.size();
            for(Opportunity o : olist){
                if(o.Amount != NULL){
                    total+=o.Amount;
                    n++;
                }
            }
            if(n>0){
                acc.Average_Opp__c = total/n;
            }
        }
        update acclist;
    }
}