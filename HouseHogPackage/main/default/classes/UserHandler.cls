public class UserHandler {

    // BEFORE_INSERT
    public static void DeactivateUsers(List<User> insertedUsers) {
        for (User newUser : insertedUsers) {
            newUser.isActive = false;
        }
    }

    // BEFORE_INSERT
    public static void AddDefaultRole(List<User> insertedUsers) {
        ID defaultRoleID = [SELECT id FROM UserRole WHERE name = 'Default' LIMIT 1].id;
        for (User newUser : insertedUsers) {
            newUser.UserRoleId = defaultRoleID;
        }
    }

    // BEFORE_INSERT
    // BEFORE_UPDATE
    // Ensure that all entity names refer to valid Agencies or Banks
    public static void UpdateProfile(List<User> userList) {
        Map<String, ID> pNameToId = ProfileIdMap(new Set<String>{'Realtor', 'Banker', 'Community'});

        for (User u : userList) {
            String type = GetUserType(u);
            if (type == 'Standard' || type == null) { continue; }

            ID expectedProfile = pNameToId.get(type);
            if (u.ProfileId != expectedProfile) {
                u.ProfileId = expectedProfile;
            }
        }
    }

    public static Map<String, ID> ProfileIDMap(Set<String> names) {
        Map<String, ID> result = new Map<String, ID>();
        for (Profile p : [SELECT id, name FROM Profile WHERE name IN :names]) {
            result.put(p.name, p.id);
        }
        return result;
    }

    // BEFORE_INSERT
    // BEFORE_UPDATE
    // Ensure that all entity names refer to valid Agencies or Banks
    public static void ValidateEntityNames(List<User> insertedUsers) {
        Map<String, Set<String>> entityMapByType = UserTypeToEntityNames(insertedUsers);

        // Filter to existing agency or bank names, and map to ID
        Map<String, Map<String, ID>> existingEntitiesByType = new Map<String, Map<String, ID>>();
        existingEntitiesByType.put('Realtor', ExistingAgencyNamesToIDs(entityMapByType.get('Realtor')));
        existingEntitiesByType.put('Banker', ExistingBankNamesToIDs(entityMapByType.get('Banker')));

        // Generate map of all entity IDs to their corresponding group IDs
        Set<ID> allEntities = new Set<ID>();
        for (ID currentID : existingEntitiesByType.get('Realtor').values()) {
            allEntities.add(currentId);
        }
        for (ID currentID : existingEntitiesByType.get('Banker').values()) {
            allEntities.add(currentId);
        }
        Map<ID, ID> mapEntityToGroup = MapEntityIdToGroupId(allEntities);

        // Add 18-digit ID to User field if entity exists (on realtor/banker types).
        // OR add error if invalid entity name for type.
        for (User newUser : insertedUsers) {
            SetUserEntityId(newUser, existingEntitiesByType, mapEntityToGroup);
        }
    }

    // AFTER_INSERT
    // Update the group membership if an Agency or Bank is included.
    public static void AddToEntityGroup(List<User> insertedUsers) {
        Map<String, Id> groupNameToID = MapGroupNameToExistingId(insertedUsers);
        GroupMember[] newMembers = new GroupMember[]{};

        for (User newUser : insertedUsers) {
            GroupMember membership = MembershipForUser(newUser, groupNameToID);
            if (membership != null) {
                newMembers.add(membership);
            }
        }
        Insert newMembers;
    }

    // AFTER_INSERT
    // Add proxy objects (Realtor or Banker) for user, given its type
    public static void AddProxyObjectsForInserted(List<User> insertedUsers) {
        Map<String, Set<ID>> IDmap = UserTypeToIDs(insertedUsers);
        AddProxyFuture(IDmap.get('Realtor'), IDmap.get('Banker'));
    }
    
    // AFTER_UPDATE
    // If entity affiliation changed, then remove from old group and add to new group
    public static void UpdateEntityGroups(Map<ID, User> newMap, Map<ID, User> oldMap) {
        System.debug('In UpdateEntityGroups');
        // Mixed operation on GroupMember -- Can't perform UPDATE (only INSERT and DELETE)
        List<User> newMemberUsers = new List<User>();
        List<User> removeMemberUsers = new List<User>();
        //List<User> changeMemberUsers = new List<User>();

        for (User updatedUser : newMap.values()) {
            ID oldEntity = oldMap.get(updatedUser.id).Entity_ID__c;
            ID newEntity = updatedUser.Entity_ID__c;

            if (oldEntity == null && newEntity != null) {
                newMemberUsers.add(updatedUser);

            }
            if (oldEntity != null && newEntity == null) {
                removeMemberUsers.add(updatedUser);

            }
            if (oldEntity != null && newEntity != null) {
                if (oldEntity != newEntity) {
                    removeMemberUsers.add(updatedUser);
                    newMemberUsers.add(updatedUser);
                    //changeMemberUsers.add(updatedUser);
                }
            }
        }

        // List<GroupMember> changes = [SELECT id, GroupId, UserOrGroupId FROM GroupMember 
        //                             WHERE UserOrGroupId IN :changeMemberUsers];
        // GroupMember[] switchGroups = new GroupMember[]{};        
        // for (GroupMember chg : changes) {
        //     User oldUser = oldMap.get(chg.UserOrGroupId);
        //     ID oldGroup = chg.GroupId;
        //     if (oldGroup == oldUser.Entity_Group_ID__c ) {
        //         chg.GroupId = newMap.get(oldUser.id).Entity_Group_ID__c;
        //         switchGroups.add(chg);
        //     }
        // }

        List<GroupMember> deletions = [SELECT id, GroupId, UserOrGroupId FROM GroupMember 
                                    WHERE UserOrGroupId IN :removeMemberUsers];
        GroupMember[] removeMembers = new GroupMember[]{};        
        for (GroupMember mem : deletions) {
            User oldUser = oldMap.get(mem.UserOrGroupId);
            ID oldGroup = mem.GroupId;
            if (oldGroup == oldUser.Entity_Group_ID__c ) {
                removeMembers.add(mem);
            }
        }

        //Update switchGroups;
        Delete removeMembers; // MUST DELETE FIRST
        AddToEntityGroup(newMemberUsers);
    }

    // AFTER_UPDATE
    // If user category changed, remove old proxy and create new proxy
    public static void ChangeProxyObjectsForUpdated(List<User> updatedUsers, Map<ID, User> oldMap) {
        List<User> changeUserProxies = new List<User>();
        Set<ID> userChangeIDSet = new Set<ID>();
        for (User updatedUser : updatedUsers) {
            if (GetUserType(updatedUser) != GetUserType(oldMap.get(updatedUser.id))) {
                changeUserProxies.add(updatedUser);
                userChangeIDSet.add(updatedUser.id);
            }
        }
        Map<String, Set<ID>> IDmap = UserTypeToIDs(changeUserProxies);

        UpdateProxyFuture(userChangeIDSet, IDmap.get('Realtor'), IDmap.get('Banker'));
    }

    
    // @future -> Avoids MIXED_DML_OPERATION error
    //     Can't perform DML on both 'setup' objects (like User)
    //     and on 'non-setup' object (e.g. custom obj) in SAME CONTEXT.
    //     Running non-setup Inserts in a @future resolves the problem.
    @future
    public static void AddProxyFuture(Set<ID> realtorUsers, Set<ID> bankerUsers) {
        AddRealtorsAndBankers(realtorUsers, bankerUsers);
    }
    @future
    public static void UpdateProxyFuture(Set<ID> removeProxiesFrom, Set<ID> realtorUsers, Set<ID> bankerUsers) {
        DeleteRealtorsAndBankers(removeProxiesFrom);
        AddRealtorsAndBankers(realtorUsers, bankerUsers);
    }

    public static void DeleteRealtorsAndBankers(Set<ID> fromUsers) {
        SObject[] removeProxies = [SELECT id FROM Realtor__c WHERE Related_User__c IN :fromUsers];
        removeProxies.addAll([SELECT id FROM Banker__c WHERE Related_User__c IN :fromUsers]);

        Delete removeProxies;
    }
    public static void AddRealtorsAndBankers(Set<ID> realtorUsers, Set<ID> bankerUsers) {
        Realtor__c[] newRealtors = new Realtor__c[]{};
        Banker__c[] newBankers = new Banker__c[]{};

        for (User newUser : [SELECT id, email, phone, Entity_ID__c, User_Category__c 
                            FROM User WHERE id IN :realtorUsers]) {
            newRealtors.add(RealtorFromUser(newUser));
        }
        for (User newUser : [SELECT id, email, phone, Entity_ID__c, User_Category__c
                            FROM User WHERE id IN :bankerUsers]) {
            newBankers.add(BankerFromUser(newUser));
        }

        Insert newBankers;
        Insert newRealtors;
    }


    public static Realtor__c RealtorFromUser(User fromUser) {
        Realtor__c newRealtor = new Realtor__c();
        String checkType = GetUserType(fromUser);

        if (checkType != 'Realtor') {
            newRealtor.addError('User is not a realtor type! Type is: ' + checkType);
            return newRealtor;
        }

        newRealtor.Related_User__c = fromUser.id;
        newRealtor.Email_Address__c = fromUser.email;
        newRealtor.Phone_Number__c = fromUser.phone;
        newRealtor.Agency__c = fromUser.Entity_ID__c;

        return newRealtor;
    }

    public static Banker__c BankerFromUser(User fromUser) {
        Banker__c newBanker = new Banker__c();
        String checkType = GetUserType(fromUser);

        if (checkType != 'Banker') {
            newBanker.addError('User is not a banker type! Type is: ' + checkType);
            return newBanker;
        }

        newBanker.Related_User__c = fromUser.id;
        newBanker.Email_Address__c = fromUser.email;
        newBanker.Phone_Number__c = fromUser.phone;
        newBanker.Bank__c = fromUser.Entity_ID__c;

        return newBanker;
    }

    public static Map<String, Id> MapGroupNameToExistingId(List<User> userList) {
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

    public static GroupMember MembershipForUser(User forUser, Map<String, Id> groupNameToID) {
        String entity = forUser.Entity_Affiliation__c;
        String prefix = getGroupPrefix(forUser);
        if (prefix == null || entity == null) {
            return null;
        }

        GroupMember membership = new GroupMember();
        String groupName = prefix + entity;

        if (!groupNameToID.containsKey(groupName)) {
            membership.addError('Group ID was not found! Validate group name and user type...');
        } else {
            // Found the correct GroupId
            ID groupID = groupNameToId.get(groupName);
            membership.GroupId = groupID;
            membership.UserOrGroupId = forUser.id;    
        }

        return membership;
    }

    public static String getGroupPrefix(User fromUser) {
        switch on GetUserType(fromUser) {
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

    public static String GetUserType(User fromUser) {
        return String.valueOf(fromUser.User_Category__c);
    }

    public static Map<String, Set<ID>> UserTypeToIDs(List<User> userList) {
        Map<String, Set<ID>> result = new Map<String, Set<ID>>();

        for (User currentUser : userList) {
            String key = GetUserType(currentUser);
            if (!result.containsKey(key)) {
                result.put(key, new Set<ID>());
            }
            result.get(key).add(currentUser.Id);
        }
        return result;
    }

    public static Map<String, Set<String>> UserTypeToEntityNames(List<User> userList) {
        // Get list of entity names in new records
        Set<String> agencyNames = new Set<String>();
        Set<String> bankNames = new Set<String>();

        Map<String, Set<String>> result = new Map<String, Set<String>>();
        for (User u : userList) {
            String entity = u.Entity_Affiliation__c;
            if (entity == null) { continue; }

            String key = GetUserType(u);
            if (!result.containsKey(key)) {
                result.put(key, new Set<String>());
            }
            result.get(key).add(entity);
        }
        return result;
    }

    public static void SetUserEntityId(User forUser, 
            Map<String, Map<String, ID>> userTypeToEntityToID,
            Map<ID, ID> entityIdToGroupId
        ) {
        // NOTE: Entity Id will simply be ignored!
        //       Entity Affiliation name must be used!
        String entity = forUser.Entity_Affiliation__c;
        if (entity == null) {
            forUser.Entity_ID__c = null;
            forUser.Entity_Group_ID__c = null;
        }

        // Only update entity ID if entity is not null
        if (entity != null) {
            String userType = GetUserType(forUser);
            if (userTypeToEntityToID.containsKey(userType)) {
                Map<String, ID> entityToId = userTypeToEntityToID.get(userType);

                if (entityToId.containsKey(entity)) {
                    ID entityID = entityToId.get(entity);

                    forUser.Entity_ID__c = entityID;
                    forUser.Entity_Group_ID__c = entityIdToGroupId.get(entityID);
                } else {
                    forUser.addError('User entity affiliation is not a valid  for ' + userType);
                }
            } else {
                // Should only occur if user type is not 'Realtor' or 'Banker'
                forUser.Entity_ID__c = null;
                forUser.Entity_Group_ID__c = null;
                forUser.Entity_Affiliation__c = null;
            }
        }
    }

    public static Map<ID, ID> MapEntityIdToGroupId(Set<ID> entities) {
        Map<ID, ID> result = new Map<ID, ID>();
        for (Bank__c b : [SELECT id, GroupId__c FROM Bank__c WHERE id IN :entities]) {
            result.put(b.id, b.GroupId__c);
        }
        for (Agency__c a : [SELECT id, GroupId__c FROM Agency__c WHERE id IN :entities]) {
            result.put(a.id, a.GroupId__c);
        }
        return result;
    }
}
