/**
 * workトリガー
 */
trigger WorkTrigger on work__c (before insert, after insert) {
  WorkTriggerHandler handler = new WorkTriggerHandler();
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      handler.onBeforeInsert(Trigger.new);
    }
  }
  else if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      handler.onAfterInsert(Trigger.new);
    }
  }
}