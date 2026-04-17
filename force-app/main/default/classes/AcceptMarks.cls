public class AcceptMarks {
    public static void printgrade(Integer marks){
        if(marks>=90){
            System.debug('A');
        }
        else if(marks>=80){
            System.debug('B');
        }
        else if(marks>=60){
            System.debug('C');
        }
        else if(marks>=40){
            System.debug('D');
        }
        else{
            System.debug('Fail');
        }
    }
}