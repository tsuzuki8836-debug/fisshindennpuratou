global class BulkApprovalWebService {
    /**
   * Bulk approve records from list view
   * @param  recordIds List<Id>
   * @return JSON String
   */
    webservice static String bulkApproval(List<Id> recordIds) {
        Map<String, Object> response = new Map<String, Object>();
    try{
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :recordIds ];
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setAction('Approve');
            req.setComments('承認します');
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
    } catch ( Exception ex ){
        response.put('status', '500');
        response.put('error', ex.getMessage());
        return JSON.serialize(response);
    }
    response.put('status', '200');
    return JSON.serialize(response);
    }
}