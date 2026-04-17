@isTest
public class testaddtwonos {
    @isTest
    public static void checksum(){
        Integer c = addtwonos.addition(10, 20);
        System.assertNOTEquals(25, c, 'Match');
    }
}