public class UserHandler {

    // BEFORE_INSERT
    public static void DeactivateUsers(List<User> insertedUsers) {
        for (User newUser : insertedUsers) {
            newUser.isActive = false;
        }
    }

    // BEFORE_INSERT
    // Ensure that all entity names refer to valid Agencies or Banks
    public static void ValidateEntityNames(List<User> insertedUsers) {
        
        // Get list of entity names in new records
        Set<String> agencyNames = new Set<String>();
        Set<String> bankNames = new Set<String>();
        for (User newUser : insertedUsers) {
            String entity = newUser.Entity_Affiliation__c;

            if (entity == null) { continue; }

            String userType = String.valueOf(newUser.User_Type__c);
            switch on userType {
                when 'Realtor' { agencyNames.add(entity); }
                when 'Banker' { bankNames.add(entity); }
                // No action if not a Realtor or Banker type.
            }
        }

        // Filter to existing agency or bank names, map to ID
        Map<String, ID> agencyMatches = ExistingAgencyNamesToIDs(agencyNames);
        Map<String, ID> bankMatches = ExistingBankNamesToIDs(bankNames);

        // Add 18-digit ID to User field if entity exists (on realtor/banker types).
        // Add error if entity doesn't exist
        // Add error if entity not null, but type isn't Realtor or Banker
        for (User newUser : insertedUsers) {
            if (newUser.Entity_ID__c != null) {
                newUser.addError('Entity ID must be set in Apex only!');
                continue;
            }

            String entity = newUser.Entity_Affiliation__c;
            String userType = String.valueOf(newUser.User_Type__c);

            switch on userType {
                when 'Realtor' {
                    if (entity != null && agencyMatches.containsKey(entity)) {
                        newUser.Entity_ID__c = agencyMatches.get(entity);
                    } else {
                        newUser.addError('User entity affiliation is not a valid Agency!');
                    }
                }
                when 'Banker' {
                    if (entity != null && bankMatches.containsKey(entity)) {
                        newUser.Entity_ID__c = bankMatches.get(entity);
                    } else {
                        newUser.addError('User entity affiliation is not a valid Bank!');
                    }
                }
                when else {
                    if (entity != null) {
                        newUser.addError('Only Realtor or Banker types can have an entity affiliation!');
                    }
                }
            }
        }
    }

    // AFTER_INSERT
    // Update the group membership if an Agency or Bank is included.
    public static void AddToEntityGroup(List<User> insertedUsers) {
        Map<String, Id> groupNameToID = MapGroupNameToId(insertedUsers);
        GroupMember[] newMembers = new GroupMember[]{};

        for (User newUser : insertedUsers) {
            String entity = newUser.Entity_Affiliation__c;
            String prefix = getGroupPrefix(newUser);

            // Prefix and entity validated BEFORE insert.
            // Skip user if no membership to add.
            if (prefix == null || entity == null) {
                continue;
            }

            GroupMember membership = new GroupMember();
            String groupName = prefix + entity;

            if (!groupNameToID.containsKey(groupName)) {
                // Should be unreachable by triggers
                membership.addError('Group ID was not found! Validate group name and user type...');
            } else {
                // Found the correct GroupId
                ID groupID = groupNameToId.get(groupName);
                membership.GroupId = groupID;
                membership.UserOrGroupId = newUser.id;    
            }

            newMembers.add(membership);
        }

        Insert newMembers;
    }

    // AFTER_INSERT
    // Add proxy objects (Realtor or Banker) for user, given its type
    public static void AddProxyObjects(List<User> insertedUsers) {
        Set<ID> realtorUserIDs = new Set<ID>();
        Set<ID> bankerUserIDs = new Set<ID>();
        
        for (User newUser : insertedUsers) {
            String userType = String.valueOf(newUser.User_Type__c);

            switch on userType {
                when 'Realtor' { realtorUserIDs.add(newUser.id); }
                when 'Banker' { bankerUserIDs.add(newUser.id); }
                // No action if not a Realtor or Banker type.
            }
        }

        AddRealtorsAndBankers(realtorUserIDs, bankerUserIDs);
    }
    //
    // @future -> Avoids MIXED_DML_OPERATION error
    //     Can't perform DML on both 'setup' objects (like User)
    //     and on 'non-setup' object (e.g. custom obj) in SAME CONTEXT.
    //     Running non-setup Inserts in a @future resolves the problem.
    @future
    public static void AddRealtorsAndBankers(Set<ID> realtorUsers, Set<ID> bankerUsers) {
        Realtor__c[] newRealtors = new Realtor__c[]{};
        Banker__c[] newBankers = new Banker__c[]{};

        for (User newUser : [SELECT id, email, phone, Entity_ID__c, User_Type__c 
                            FROM User WHERE id IN :realtorUsers]) {
            newRealtors.add(RealtorFromUser(newUser));
        }

        for (User newUser : [SELECT id, email, phone, Entity_ID__c, User_Type__c
                            FROM User WHERE id IN :bankerUsers]) {
            newBankers.add(BankerFromUser(newUser));
        }

        Insert newBankers;
        Insert newRealtors;
    }

    public static Realtor__c RealtorFromUser(User fromUser) {
        Realtor__c newRealtor = new Realtor__c();

        // Add error if user is not a realtor
        String checkType = String.valueOf(fromUser.User_Type__c);

        if (checkType != 'Realtor') {
            newRealtor.addError('User is not a realtor type! Type is: ' + checkType);
            return newRealtor;
        }

        //newRealtor.OwnerId = fromUser.id;
        newRealtor.Email_Address__c = fromUser.email;
        newRealtor.Phone_Number__c = fromUser.phone;
        newRealtor.Agency__c = fromUser.Entity_ID__c;

        return newRealtor;
    }

    public static Banker__c BankerFromUser(User fromUser) {
        Banker__c newBanker = new Banker__c();

        // Add error if user is not a banker
        String checkType = String.valueOf(fromUser.User_Type__c);

        if (checkType != 'Banker') {
            newBanker.addError('User is not a banker type! Type is: ' + checkType);
            return newBanker;
        }

        //newBanker.OwnerId = fromUser.id;
        newBanker.Email_Address__c = fromUser.email;
        newBanker.Phone_Number__c = fromUser.phone;
        newBanker.Bank__c = fromUser.Entity_ID__c;

        return newBanker;
    }

    public static Map<String, Id> MapGroupNameToId(List<User> userList) {
        Map<String, Id> result = new Map<String, Id>();

        // Add appropriate prefix to group names, put into Set
        Set<String> groupNames = new Set<String>();
        for (User newUser : userList) {
            String prefix = getGroupPrefix(newUser);
            if (prefix != '') {
                groupNames.add(prefix + newUser.Entity_Affiliation__c);
            } 
        }

        for (Group currentGroup : [SELECT name, id FROM Group WHERE name IN :groupNames]) {
            result.put(currentGroup.name, currentGroup.id);
        }

        return result;
    }

    public static String getGroupPrefix(User fromUser) {
        String userType = String.valueOf(fromUser.User_Type__c);

        switch on userType {
            when 'Realtor' { return 'agencyGrp'; }
            when 'Banker' { return 'bankGrp'; }
        }
        return '';
    }

    public static Map<String, ID> ExistingAgencyNamesToIDs(Set<String> agencyNames) {
        Map<String, ID> output = new Map<String, ID>();
        for (Agency__c a : [SELECT name, id FROM Agency__c WHERE name IN :agencyNames]) {
            output.put(a.name, a.id);
        }
        return output;
    }

    public static Map<String, ID> ExistingBankNamesToIDs(Set<String> bankNames) {
        Map<String, ID> output = new Map<String, ID>();
        for (Bank__c b : [SELECT name, id FROM Bank__c WHERE name IN :bankNames]) {
            output.put(b.name, b.id);
        }
        return output;
    }
}
