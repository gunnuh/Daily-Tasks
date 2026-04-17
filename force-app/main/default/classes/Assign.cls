public class Assign {
    public static void method() {

        Datetime sd = Datetime.valueOf('2016-01-02 06:07:55');
        Datetime ed = Datetime.valueOf('2018-02-05 07:08:55');
        Long diffsec = (ed.getTime() - sd.getTime()) / 1000;
        Long sec = Math.mod(diffsec, 60);
        Long totalmins = diffsec / 60;
        Long mins = Math.mod(totalmins, 60);
        Long totalhrs = totalmins / 60;
        Long hrs = Math.mod(totalhrs, 24);
        Long totaldays = totalhrs / 24;
        Long days = Math.mod(totaldays, 30);
        Long totalMonths = totaldays / 30;
        Long months = Math.mod(totalMonths, 12);
        Long years = totalMonths / 12;
        System.debug('Years: ' + years);
        System.debug('Months: ' + months);
        System.debug('Days: ' + days);
        System.debug('Hours: ' + hrs);
        System.debug('Minutes: ' + mins);
        System.debug('Seconds: ' + sec);
    }
}