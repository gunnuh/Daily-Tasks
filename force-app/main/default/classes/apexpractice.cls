public class apexpractice {
    public static void createacc(){
        Account acc=[select Name, Phone from Account where Name='Hania Amir'];
        acc.Phone='123456';
        update acc;
    }
}