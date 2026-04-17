public class binary {
    public static void method(String n1, String n2){
        Integer i=n1.length()-1;
        Integer j=n2.length()-1;
        Integer carry=0;
        String result='';
        while(i>=0 || j>=0 || carry==1){
            Integer sum=carry;
            if(i>=0){
                sum+=Integer.valueOf(n1.substring(i,i+1));
                i--;
            }
            if(j>=0){
                sum+=Integer.valueOf(n2.substring(j,j+1));
                j--;
            }
            result=String.valueOf(Math.mod(sum,2))+result;
            carry=sum/2;
        }
        System.debug(result);
    }
}