public class BankHandler {

    // Create Groups for each added bank, and add Group ID to bank field before insert.
    public static void CreateBankGroups(List<Bank__c> insertedBanks) {

        Group[] bankGroups = new Group[]{};

        for (Bank__c newBank: insertedBanks) {
            // Create new group for each bank
            Group newGroup = new Group();
            newGroup.Name = 'bankGrp' + newBank.name;
            newGroup.DoesIncludeBosses = false; 

            bankGroups.add(newGroup);
        }
        
        Insert bankGroups;
        
        // Convert to Map
        Map<String, Id> groupMap = new Map<String, Id>();
        for (Group bankGroup : bankGroups) {
            groupMap.put(bankGroup.name, bankGroup.Id);
        }

        // Add references to the added groups...
        for (Bank__c newBank : insertedBanks) {
            newBank.GroupId__c = groupMap.get('bankGrp' + newBank.name);
        }
    }
}
