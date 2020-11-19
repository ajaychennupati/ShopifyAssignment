trigger JobsTrigger on Job__c (After Update) {
     JobsTriggerhelper.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
}