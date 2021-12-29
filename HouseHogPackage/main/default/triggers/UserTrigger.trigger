trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType {
        when BEFORE_INSERT {
            UserHandler.DeactivateUsers(trigger.new); // DEFAULT INACTIVE
            UserHandler.ValidateEntityNames(trigger.new);
        }
        when BEFORE_UPDATE {
            UserHandler.ValidateEntityNames(trigger.new);
        }
        when BEFORE_DELETE {} // CANNOT DELETE USERS
        when AFTER_INSERT {
            UserHandler.AddToEntityGroup(trigger.new);
            UserHandler.AddProxyObjectsForInserted(trigger.new);
        }
        when AFTER_UPDATE {
            UserHandler.UpdateEntityGroups(trigger.newMap, trigger.oldMap);
            UserHandler.ChangeProxyObjectsForUpdated(trigger.new, trigger.oldMap);
        }
        when AFTER_DELETE {}
        when AFTER_UNDELETE {}
    }
}