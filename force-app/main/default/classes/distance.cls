public class distance {
    public static void method(){
        try{
            Map<String, Integer> locDistance = new Map<String, Integer>{
            'A' => 0, 'B' => 10, 'C' => 30, 'D' => 68, 'E' => 151, 'F' => 224
        };
        List<Order_Location__c> orders = [SELECT Id, Travel_Location__c, Total_Distance__c, Account__r.Location__c FROM Order_location__c
            WHERE Account__r.Location__c IN ('A','F')
        ];        
        for(Order_Location__c o : orders){      
            Integer travelDist = locDistance.get(o.Travel_Location__c);
            Integer accDist = locDistance.get(o.Account__r.Location__c);
            if(travelDist != null && accDist != null){
                o.Total_Distance__c = Math.abs(travelDist - accDist);
            }
        }
        update orders;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}