public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getCon(String accname){
        return [select Id, Name, Email, Phone from Contact  where Account.Name = :accname];
    }
}