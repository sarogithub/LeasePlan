trigger caseTrigger on Case (before insert, before update, before delete, after insert,
                                                after update, after delete, after undelete) {
    TriggerHandlerFactory.run(Trigger.operationType);
}