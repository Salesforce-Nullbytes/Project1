trigger OrderDeleteTrigger on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType{
        when BEFORE_DELETE{
            System.debug('In trigger');
            OrderController.preventDeleteWithRecentOrder(trigger.old);
        }
    }
}

