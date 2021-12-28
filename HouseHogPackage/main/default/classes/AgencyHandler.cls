public class AgencyHandler {
    public static void CreateAgencyGroups(List<Agency__c> insertedAgencies) {
        Group[] agencyGroups = new Group[]{};

        for (Agency__c newAgency: insertedAgencies) {
            // Create new group for agency
            Group newGroup = new Group();
            newGroup.Name = 'agencyGrp' + newAgency.name;
            newGroup.DoesIncludeBosses = false; 

            agencyGroups.add(newGroup);
        }
        if (agencyGroups.size() > 0) {
            Insert agencyGroups;
        }
    }
}
