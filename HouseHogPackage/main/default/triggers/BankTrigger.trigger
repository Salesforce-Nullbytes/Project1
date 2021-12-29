trigger BankTrigger on Bank__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType {
        when BEFORE_INSERT {
            BankHandler.CreateBankGroups(trigger.new);
        }
        when BEFORE_UPDATE {}
        when BEFORE_DELETE {}
        when AFTER_INSERT {}
        when AFTER_UPDATE {}
        when AFTER_DELETE {}
        when AFTER_UNDELETE {}
    }
}