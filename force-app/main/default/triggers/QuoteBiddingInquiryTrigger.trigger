/**
 * 見積・応札伺いトリガー
 */
trigger QuoteBiddingInquiryTrigger on QuoteBiddingInquiry__c (before insert, before update, before delete,after insert, after update) {

    QuoteBiddingInquiryHandler handler = new QuoteBiddingInquiryHandler();

    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.new,Trigger.newMap, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new,Trigger.newMap);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }
}