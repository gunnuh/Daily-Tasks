public class OLIHandler {
   public static void updateTotalOpp(List<OpportunityLineItem> items) {
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : items) {
            oppIds.add(oli.OpportunityId);
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, AccountId, Amount FROM Opportunity WHERE Id IN :oppIds]
        );
        Set<Id> accIds = new Set<Id>();
        for (Opportunity opp : oppMap.values()) {
            if (opp.AccountId != null) {
                accIds.add(opp.AccountId);
            }
        }
        List<Account> accList = [SELECT Id FROM Account WHERE Id IN :accIds];
        for (Account acc : accList) {
            Decimal total = 0;
            List<Opportunity> opps = [SELECT Amount FROM Opportunity WHERE AccountId = :acc.Id];
            for (Opportunity o : opps) {
                if (o.Amount != null) {
                    total += o.Amount;
                }
            }
            acc.Total_Opportunity__c = total;
        }
        update accList;
    }
}