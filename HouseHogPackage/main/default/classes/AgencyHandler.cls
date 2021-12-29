public class AgencyHandler {

    // Create Groups for each added agency, and add Group ID to agency field before insert.
    public static void CreateAgencyGroups(List<Agency__c> insertedAgencies) {

        Group[] agencyGroups = new Group[]{};

        for (Agency__c newAgency: insertedAgencies) {
            // Create new group for each agency
            Group newGroup = new Group();
            newGroup.Name = 'agencyGrp' + newAgency.name;
            newGroup.DoesIncludeBosses = false; 

            agencyGroups.add(newGroup);
        }
        
        Insert agencyGroups;
        
        // Convert to Map
        Map<String, Id> groupMap = new Map<String, Id>();
        for (Group agencyGroup : agencyGroups) {
            groupMap.put(agencyGroup.name, agencyGroup.Id);
        }

        // Add references to the added groups...
        for (Agency__c newAgency: insertedAgencies) {
            newAgency.GroupId__c = groupMap.get('agencyGrp' + newAgency.name);
        }
    }
}
