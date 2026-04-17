public class oddeven {
    public void ck(Integer n){
        Integer r=Math.mod(n,2);
        if(r==0){
            System.debug('even');
        }
        else{
            System.debug('odd');
        }
    }
}