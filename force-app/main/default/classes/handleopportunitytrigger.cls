public class handleopportunitytrigger {
    @AuraEnabled
    public static List<Map<String, Object>> getOppRecords(){
        try {
            List<Opportunity> oppList = [SELECT Id, AccountId, Account.Name, Name, Amount, StageName FROM Opportunity];
            List<Map<String, Object>> result = new List<Map<String, Object>>();
            for (Opportunity opp : oppList) {
                Map<String, Object> row = new Map<String, Object>();
                row.put('Id', opp.Id);
                row.put('AccountId', opp.AccountId);
                row.put('AccountName', opp.Account != null ? opp.Account.Name : '');
                row.put('Name', opp.Name);
                row.put('Amount', opp.Amount);
                row.put('StageName', opp.StageName);
                result.add(row);
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching opportunities: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getOppFields(){
        try {
            Schema.SObjectType opportunityType = Schema.getGlobalDescribe().get('Opportunity');
            Map<String,Schema.SObjectField> mfields = opportunityType.getDescribe().fields.getMap();
            List<String> sObjectDetailsList = new List<String>();
            for(String s : mfields.keySet()) {
                sObjectDetailsList.add(mfields.get(s).getDescribe().getLabel());
            }
            return sObjectDetailsList;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching opportunity fields: ' + e.getMessage());
        }
    }

    public static void handleAfterInsert(List<Opportunity> newOpps){
        try {
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp : newOpps){
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
            }
            if(!accountIds.isEmpty()){
                updateAccountMinMax(accountIds);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error in handleAfterInsert: ' + e.getMessage());
        }
    }

    public static void handleAfterUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap){
        try {
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp : newOpps){
                Opportunity oldOpp = oldMap.get(opp.Id);
                if(opp.AccountId != oldOpp.AccountId){
                    if(oldOpp.AccountId != null) accountIds.add(oldOpp.AccountId);
                    if(opp.AccountId != null)    accountIds.add(opp.AccountId);
                } else if(opp.Amount != oldOpp.Amount){
                    if(opp.AccountId != null)    accountIds.add(opp.AccountId);
                }
            }
            if(!accountIds.isEmpty()){
                updateAccountMinMax(accountIds);
            }
        } catch (Exception e) {
          
            System.debug('Error in handleAfterUpdate: ' + e.getMessage());
        }
    }

    private static void updateAccountMinMax(Set<Id> accountIds){
        try {
            Map<Id, Decimal> maxMap = new Map<Id, Decimal>();
            Map<Id, Decimal> minMap = new Map<Id, Decimal>();
    
            for(AggregateResult ar : [
                SELECT AccountId accId, MAX(Amount) maxAmt, MIN(Amount) minAmt
                FROM Opportunity
                WHERE AccountId IN :accountIds AND Amount != NULL
                GROUP BY AccountId
            ]){
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
        } catch (DmlException e) {
            System.debug('DML Error in updateAccountMinMax: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Error in updateAccountMinMax: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getAccounts(){
        try {
            List<Account> accList = [SELECT Id, Name FROM Account ORDER BY Name];
            List<Map<String,String>> options = new List<Map<String,String>>();
            for(Account acc : accList){
                options.add(new Map<String,String>{
                    'label' => acc.Name,
                    'value' => acc.Id
                });
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching accounts: ' + e.getMessage());
        }
    }
}