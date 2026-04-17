public class ContactHandler {
    public static void updateParentContact(List<Contact> conList){
        Set<Id> accIds = new Set<Id>();
        for(Contact c : conList){
            if(c.Checkbox__c == true && c.AccountId != null){
                accIds.add(c.AccountId);
            }
        }
        List<Account> accList = [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accIds];
        List<Account> updateAcc = new List<Account>();
        for(Account acc : accList){
            if(acc.Contacts.size() == 1){
                acc.Parent_Contact__c = acc.Contacts[0].Id;
                updateAcc.add(acc);
            }
        }
        update updateAcc;
    }
}