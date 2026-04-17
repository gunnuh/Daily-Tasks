public class accounttriggerhandler {
    public static Boolean isRunning = false;
    public static void handleUpdate(List<Account> newList) {
        if(isRunning == true){
            return;
        }
        isRunning = true;
        for(Account acc : newList){
            acc.Description = 'Updated';
        }
    }
}