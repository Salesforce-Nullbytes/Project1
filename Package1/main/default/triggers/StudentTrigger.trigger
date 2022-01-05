trigger StudentTrigger on Student__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType {
        when BEFORE_INSERT {
            StudentHandler.AssignStudentLevel(trigger.new);
        }
    }
}