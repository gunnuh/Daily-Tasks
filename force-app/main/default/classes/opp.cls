public class opp {
    public enum os{
        add,sub,mul,div
    }
    public void calc(Integer a, Integer b, os operator){
        if(operator==os.add){
            System.debug(a+b);
        }
        else if(operator==os.sub){
            System.debug(a-b);
        }
        else if(operator==os.mul){
            System.debug(a*b);
        }
        else if(operator==os.div){
            System.debug(a/b);
        }
    }
}