public class testSFInteg {
    @future(callout=true)
    public static void getDetails(){
        HttpRequest req=new HttpRequest();
        req.setEndpoint('callout:SFInteg/services/apexrest/Account/');
        req.setHeader('content-type','application/json;charset=UTF-8');
        req.setHeader('Accept','application/json');
        req.setMethod('GET');
        Http http=new Http();
        HttpResponse res=http.send(req);
        System.debug('Response Code: '+ res.getStatusCode());
        System.debug('Response Body: '+res.getBody());
    }
    @future(callout=true)
    public static void postDetails(String accName){
        HttpRequest req=new HttpRequest();
        req.setEndpoint('callout:SFInteg/services/apexrest/Account/');
        req.setHeader('content-type','application/json;charset=UTF-8');
        req.setHeader('Accept','application/json');
        req.setBody('{"accName":"' + accName + '"}');
        req.setMethod('POST');
        Http http=new Http();
        HttpResponse res=http.send(req);
        System.debug('Response Code: '+ res.getStatusCode());
        System.debug('Response Body: '+res.getBody());
    }
}