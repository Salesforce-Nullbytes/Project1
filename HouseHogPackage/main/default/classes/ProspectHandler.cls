public class ProspectHandler {
    // BEFORE_INSERT
    // Add references to the realtors selling and purchasing the home
    public static void AttachRealtors(List<Prospect__c> insertedProspects) {
        Set<ID> accountIDs = new Set<ID>();
        Set<ID> propertyIDs = new Set<ID>();
        for (Prospect__c p : insertedProspects) {
            accountIDs.add(p.Account__c);
            propertyIDs.add(p.Property__c);
        }

        // Map properties to accounts
        Map<ID, ID> propertyToOwner = new Map<ID, ID>();
        for (Property__c property : [SELECT id, Property_Owner__c FROM Property__c WHERE id IN :propertyIDs]) {
            accountIDs.add(property.Property_Owner__c);
            propertyToOwner.put(property.id, property.Property_Owner__c);
        }

        // Map accounts to realtors
        Map<ID, ID> accountToRealtor = new Map<ID, ID>();
        for (Account a : [SELECT id, Realtor__c FROM Account WHERE id IN :accountIDs]) {
            accountToRealtor.put(a.id, a.Realtor__c);
        }
        
        // Update buying and selling realtor on each property
        for (Prospect__c p : insertedProspects) {
            p.Purchasing_Realtor__c = accountToRealtor.get(p.Account__c);

            ID propertyAccount = propertyToOwner.get(p.Property__c);
            p.Selling_Realtor__c = accountToRealtor.get(propertyAccount);
        }
    }

}
