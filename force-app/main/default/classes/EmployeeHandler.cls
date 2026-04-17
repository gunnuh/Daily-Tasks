public class EmployeeHandler {
    public static void undeleteemployee(List<Employee__c>emplist){
        List<Employee__c> updateemp = new List<Employee__c>();
        for(Employee__c e:emplist){
            e.Active__c=true;
            updateemp.add(e);
        }
        update updateemp;
    }
}