public class grading {
    public void gr(Integer rn, Integer m1, Integer m2, Integer m3){
        Integer t=m1+m2+m3;
        Integer avg=t/3;
        System.debug(t);
        System.debug(avg);
        if(avg>=60){
            System.debug('A');
        }
        else if(avg>=50 && avg<60){
            System.debug('B');
        }
        else {
            System.debug('C');
        }
    }
}