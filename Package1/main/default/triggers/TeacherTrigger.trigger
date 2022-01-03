trigger TeacherTrigger on Teacher__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType {
        when BEFORE_INSERT {
            TeacherHandler.AssignTeacherStatus(trigger.new);
        }
    }
}