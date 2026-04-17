public class ques12 {
    public Integer fun(Integer n){
        Integer r=Math.mod(n, 2);
        if(r!= 0){
            //System.debug('odd number');
            return 2;
        }
        else{
            return 1;
        }
    }
}