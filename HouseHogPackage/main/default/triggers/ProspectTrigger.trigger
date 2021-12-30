trigger ProspectTrigger on Prospect__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType {
        when BEFORE_INSERT {
            ProspectHandler.ValidateInsertStatusAndApplyDate(trigger.new);
            ProspectHandler.AttachRealtors(trigger.new);
        }
        when BEFORE_UPDATE {
            ProspectHandler.ValidateStatusChange(trigger.new, trigger.oldMap);
            ProspectHandler.ApplyDates(trigger.new, trigger.oldMap);
            ProspectHandler.UpdatePendingSalePrices(trigger.new, trigger.oldMap);
            ProspectHandler.ValidatePrices(trigger.new, trigger.oldMap);
            // Don't update Realtors automatically...
            // Buyer or home owner may elect to do so or keep existing.
        }
        when BEFORE_DELETE {
            ProspectHandler.PreventInvalidDeletions(trigger.old);
        }
        when AFTER_INSERT {}
        when AFTER_UPDATE {}
        when AFTER_DELETE {}
        when AFTER_UNDELETE {}
    }
}