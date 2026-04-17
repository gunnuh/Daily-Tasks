public class AccountServiceSFAPI {
    public static void getData(List<Account>accList, Map<Id,Account> oldMap){
        system.debug('get data function called');
        Set<Id> accids = new Set<Id>();
        for(Account acc : accList){
            if(Trigger.isInsert){
                accids.add(acc.Id);
            }
            else{
                Account oldacc = oldMap.get(acc.Id);
                if(acc.Name!=oldacc.Name||acc.Phone!=oldacc.Phone||acc.Website!=oldacc.Website||acc.Industry!=oldacc.Industry||acc.BillingCity!=oldacc.BillingCity){
                    accids.add(acc.Id);
                }
            }
        }
        if(!accids.isEmpty()){
            AccountServiceSFAPI.postDetails(accids);
        }
    }
    @future(callout=true)
    public static void postDetails(Set<Id> accountIds){
        system.debug('post details');
        List<Account> acclist = [select Id, Name, Phone, Website, Industry, BillingCity, Target_Id__c from Account where Id IN :accountIds];
        List<Account> accountsToUpdate = new List<Account> ();
        for(Account acc : acclist){
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SFInteg/services/apexrest/Account');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            Map<String, Object> mapAccount = new Map<String, Object>();
            mapAccount.put('SourceId', acc.Id);
            mapAccount.put('name', acc.Name);
            mapAccount.put('phone', acc.Phone);
            mapAccount.put('website', acc.Website);
            mapAccount.put('industry', acc.Industry);
            mapAccount.put('billingCity', acc.BillingCity);
            mapAccount.put('billingCountry', acc.BillingCountry);
            
            req.setBody(JSON.serialize(mapAccount));
            Http ht = new Http();
            HttpResponse res = ht.send(req);
            
            if(res.getStatusCode() == 200){
                acc.Target_Id__c = res.getBody();
                accountsToUpdate.add(acc);
            }
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}