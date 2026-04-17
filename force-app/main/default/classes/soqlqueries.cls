public class soqlqueries {
    public static void method(){
        List<Account> acclist = [select Id, Name from Account where ID IN (Select AccountId from opportunity)];
        for(Account a:acclist){
            System.debug('Account Id:'+a.Id+' '+'Name:'+a.Name);
        }
    }
}