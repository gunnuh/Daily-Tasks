public class updateclass {
    public static void checkaccount(List<Account> acclist){
        Set<String> accName = new Set<String>();
        for(Account a: acclist){
            accName.add(a.Name);
        }
        for(Account acc : acclist){
            if(accName.contains(acc.Name)){
                acc.addError('Account already exists');
            }
            else{
                accName.add(acc.Name);
            }
        }        
    }
}