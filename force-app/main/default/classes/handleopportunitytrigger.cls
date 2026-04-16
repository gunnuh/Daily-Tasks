public class handleopportunitytrigger {
    @AuraEnabled(cacheable=true)
    public static List<String> getOpportunityFields(){
        try {
            Schema.SObjectType opportunityType = Schema.getGlobalDescribe().get('Opportunity');
            Map<String,Schema.SObjectField> mfields = opportunityType.getDescribe().fields.getMap();
            List<String> sObjectDetailsList = new List<String>();
            for(String s : mfields.keySet()) {
                sObjectDetailsList.add(s);
            }
            return sObjectDetailsList;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching opportunity fields: ' + e.getMessage());
        }
    }
    public static void handleAfterInsert(List<Opportunity> newOpps){
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : newOpps){
            if(opp.AccountId != null){
                accountIds.add(opp.AccountId);
            }
        }
        if(!accountIds.isEmpty()){
            updateAccountMinMax(accountIds);
        }
    }
    public static void handleAfterUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap){
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : newOpps){
            Opportunity oldOpp = oldMap.get(opp.Id);
            //reparenting
            if(opp.AccountId != oldOpp.AccountId){
                if(oldOpp.AccountId != null){
                    accountIds.add(oldOpp.AccountId);
                }
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
            }
            else if(opp.Amount != oldOpp.Amount){
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
            }
        }
        if(!accountIds.isEmpty()){
            updateAccountMinMax(accountIds);
        }
    }

    private static void updateAccountMinMax(Set<Id> accountIds){
        Map<Id, Decimal> maxMap = new Map<Id, Decimal>();
        Map<Id, Decimal> minMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [SELECT AccountId accId,MAX(Amount) maxAmt, MIN(Amount) minAmt FROM Opportunity WHERE AccountId IN :accountIds AND Amount != NULL GROUP BY AccountId]){
            maxMap.put((Id)ar.get('accId'), (Decimal)ar.get('maxAmt'));
            minMap.put((Id)ar.get('accId'), (Decimal)ar.get('minAmt'));
        }
        List<Account> accountsToUpdate = new List<Account>();
        for(Id accId : accountIds){
            Account acc = new Account();
            acc.Id = accId;
            acc.Max_Opportunity_Amount__c = maxMap.get(accId);
            acc.Min_Opportunity_Amount__c = minMap.get(accId);
            accountsToUpdate.add(acc);
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}