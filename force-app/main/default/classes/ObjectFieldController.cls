public with sharing class ObjectFieldController {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllObjects() {
    	return new List<String>(Schema.getGlobalDescribe().keySet());
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getFields(String objectName) {
        Map<String, String> fieldMap = new Map<String, String>();
        if(objectName == null) {
        	return fieldMap;
        }
        Map<String, Schema.SObjectField> fields =
        Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(String fName : fields.keySet()) {
            Schema.DescribeFieldResult f = fields.get(fName).getDescribe();
            fieldMap.put(
                f.getName(),
                f.getLabel() + ' | ' + String.valueOf(f.getType())
            );
        }
        return fieldMap;
    }
}