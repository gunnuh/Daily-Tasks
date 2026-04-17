public class pattern {
    public void printpattern(Integer n){
        for(Integer i=1; i<=n; i++){
            String line='';
            for(Integer j=1; j<=i; j++){
                line+='*';
            }
            System.debug(line);
        }
    }

}