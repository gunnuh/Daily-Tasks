public class fetchOppByFilter {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunity(){
        return [
            SELECT Id, Name, StageName, Amount FROM Opportunity LIMIT 200];
    }
}