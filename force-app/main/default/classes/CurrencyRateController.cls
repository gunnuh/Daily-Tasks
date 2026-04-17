public with sharing class CurrencyRateController {
    @AuraEnabled(cacheable=true)
    public static String getRates() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://v6.exchangerate-api.com/v6/9d71f33d087443658b64b963/latest/USD');
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            return res.getBody();
        }
        else{
            throw new AuraHandledException('API call failed');
        }
    }

    @future(callout=true)
    public static void convertCurrency(Set<Id> recordIds){
        List<Opportunity> records = [
            SELECT Id, Amount, Currency_Type__c, Converted_Amount__c
            FROM Opportunity
            WHERE Id IN :recordIds
        ];
    
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://v6.exchangerate-api.com/v6/9d71f33d087443658b64b963/latest/USD');
        req.setMethod('GET');
    
        HttpResponse res = http.send(req);
    
        if(res.getStatusCode() == 200){
            Map<String,Object> result =
                (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
    
            Map<String,Object> rates =
                (Map<String,Object>) result.get('conversion_rates');
    
            for(Opportunity rec : records){
                if(rec.Currency_Type__c != null && rec.Amount != null){
    
                    String c = rec.Currency_Type__c.toUpperCase();
                    Object rateObj = rates.get(c);
    
                    if(rateObj != null){
                        Decimal rate = Decimal.valueOf(String.valueOf(rateObj));
                        rec.Converted_Amount__c = rec.Amount * rate;
                    }
                }
            }
    
            try{
                update records;
            }
            catch(Exception e){
                System.debug('Currency update error: ' + e.getMessage());
            }
        }
    }
}