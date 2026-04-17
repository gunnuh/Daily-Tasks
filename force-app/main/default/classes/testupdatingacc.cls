@isTest
public class testupdatingacc {
    @isTest public static void checkresult(){
        Account a = new Account();
        a.Name = 'CA123';
        a.Rating = 'Warm';
        a.Active__c = 'No';
        insert a;
        Contact c=new Contact();
        c.LastName = 'Testing';
        c.AccountId = a.Id;
        insert c;
        updatingacc.updation();
        Account up = [select Id, Rating, Active__c from Account where Id=:a.Id];
        System.assertNOTEquals('Warm', up.Rating, 'Rating is not hot');
        System.assertNOTEquals('No', up.Active__c, 'Active is not YES');
    }
}