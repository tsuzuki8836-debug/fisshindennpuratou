public class UpdateCurrentApproverHandler {
    public static void updateApprovalUserOnProcessStart(List<Id> requestTaskIds) {
        List<RequestTask__c> tasksToUpdate = new List<RequestTask__c>();
        RequestTask__c task = [SELECT Id FROM RequestTask__c WHERE Id IN :requestTaskIds];
        List<ProcessInstanceStep> approvalInstances = [Select
                                                        ProcessInstance.ProcessDefinitionId,
                                                        ProcessInstance.TargetobjectId,
                                                        OriginalActor.Name,
                                                        Actor.Id
                                                        FROM ProcessInstanceStep
                                                        WHERE ProcessInstance.TargetobjectId =: requestTaskIds LIMIT 1
                                                        ];

        for (ProcessInstanceStep instance : approvalInstances) {
            task.CurrentApprover__c = instance.Actor.Id;
            tasksToUpdate.add(task);
        }
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }
}