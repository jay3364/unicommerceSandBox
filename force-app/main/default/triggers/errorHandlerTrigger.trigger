trigger errorHandlerTrigger on Error_Handler__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            errorHandlerTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap , Trigger.newMap, Trigger.old);
            triggerRecursionHelper.isTriggerExecuted = false;
        }
    }
}