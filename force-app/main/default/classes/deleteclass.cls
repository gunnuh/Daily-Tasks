public class deleteclass {
    public void fun(){
        List <Account> acclist = [select Id, Name from Account where Name ='John' LIMIT 2];
        for(Account acc: acclist){
            delete acc;
        }
    }
}