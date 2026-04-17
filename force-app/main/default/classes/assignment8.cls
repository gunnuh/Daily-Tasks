public class assignment8 {
    public static void method() {
        try {
            List<User> users = [SELECT Id, Email FROM User];
            for(User u : users){
                Integer accCount = [SELECT COUNT() FROM Account WHERE OwnerId=:u.Id AND Phone!=null];
                Integer conCount = [SELECT COUNT() FROM Contact WHERE OwnerId=:u.Id AND Email!=null];
                if(accCount>100 && conCount>30){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {u.Email});
                    mail.setSubject('Accounts and Contacts Info');
                    mail.setPlainTextBody('You have more than 100 accounts with phone and 30 contacts with email.');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                }
            }
        } catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}