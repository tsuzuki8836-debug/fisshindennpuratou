public with sharing class BulkApprovalAction {
    // Inputパラメータ  
    public class Input {
        @InvocableVariable(required=true label='レコードID')
        public List<Id> recordIds;
    }

    public class Result {
        //バッチが成功したか
        @InvocableVariable
        public Boolean success;
        //メッセージ内容
        @InvocableVariable
        public String message;
    }

    /**
     * @param recordId 承認レコードID
     * @return Result
     */
    @invocableMethod(label='一括承認')
    public static List<Result> bulkApproval(List<Input> parameters) {
        List<String> recordIds = new List<String>();
        for(Id recordId : parameters.get(0).recordIds) {
            recordIds.add(recordId);
        }

        List<result> results = new List<result>();
        Result r = new Result();
        try{
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :recordIds];
            for(ProcessInstanceWorkitem workItem : workItems){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Approve');
                req.setComments('承認します');
                requests.add(req);
            }
            Approval.ProcessResult[] processResults = Approval.process(requests);
            r.success = true;
            r.message = '承認処理が正常に完了しました。';
            results.add(r);
        } catch ( Exception ex ){
            r.success = false;
            r.message = '承認処理が失敗しました。';
            results.add(r);
        }
        return results;
    }
}