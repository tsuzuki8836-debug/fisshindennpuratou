public class SendEmailFromRequestTask {

    /**
     * メール送信（社内送信先1～10宛）
     * 以下から呼び出し
     * ・依頼タスクメール送信用フロー(SendEmailFromRequestTask)から起動
     */
    @InvocableMethod(label='Send Email from request Task')
    public static void sendEmails(List<Id> requestTaskIds){
        sendRequestTaskEmails(requestTaskIds);
    }

    /**
     * メール送信
     * @param requestTaskIds 依頼タスクのIDリスト
     */
    public static void sendRequestTaskEmails(List<Id> requestTaskIds){

        //メールテンプレートを取得
        EmailTemplate template = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE name = '依頼タスクメール'];
        System.debug(template.Id);

        for(RequestTask__c req : getRequestTaskRecord(requestTaskIds)){
            // 宛先を取得
            List<String> emailAddresses = new List<String>();
            // 依頼先承認省略の場合は依頼先通知者1～4を追加
            if (req.SkipRequestApproval__c && req.Status__c == '依頼先対応済/依頼完了') {
                emailAddresses.addAll(getRequestNotificationList(req));
            }
            // 社内送信先1～10を追加
            emailAddresses.addAll(getEmailAddressesList(req));

            // 宛先がある場合のみメール送信
            if (emailAddresses.size() > 0) {
                sendEmail(req, emailAddresses, template);
            }
        }
    }

    /**
     * メールを送信する
     */
    public static void SendEmail(RequestTask__c req, List<String> emailAddresses, EmailTemplate template) {

        //依頼タスクコメントの改行を<BR/>に変換
        String taskDetail = '';
        if(req.TaskDetail__c != null) {
            taskDetail = req.TaskDetail__c.replaceAll( '[\\r\\n]+', '<br/>' );
        }

        //文字色が白になってしまうためテキストスタイルを適用
        String ownerName = '<span style="color: black;">'+ req.Owner.Name + '</span>';
        String commentTytle =  '<span style="color: black;">'+ '依頼コメント：' + '</span>';
        String comment =  '<span style="color: black;">'+ taskDetail + '</span>';
        String sharePointTytle =  '<span style="color: black;">'+ 'SharePoint URL：' + '</span>';
        String sharePoint =  '<span style="color: black;">'+ req.SharePoint_URL__c + '</span>';

        //メール本文をカスタム
        String emailSubject =  '「' + String.valueOf(req.Name) + '」が発信されました';
        String emailBody = template.Body;
        emailBody = replaceMessgae(emailBody, '#RequestTaskName#', req.Name);
        emailBody = replaceMessgae(emailBody, '#TaskCategory#', req.TaskCategory__c);
        emailBody = replaceMessgae(emailBody, '#DueDate#', String.valueOf(req.DueDate__c));
        emailBody = replaceMessgae(emailBody, '#OpportunityName#', req.Opportunity__r.Name);
        emailBody = replaceMessgae(emailBody, '#Requester#', String.valueOf(req.Requester__c));
        emailBody = replaceMessgae(emailBody, '#OwnerId#', ownerName);
        emailBody = replaceMessgae(emailBody, '依頼コメント：', commentTytle);
        emailBody = replaceMessgae(emailBody, '#TaskDetail#', comment);
        emailBody = replaceMessgae(emailBody, 'SharePoint URL：', sharePointTytle);
        emailBody = replaceMessgae(emailBody, '#SharepointURL#', sharePoint);
        /*
        emailBody = emailBody.replace('#RequestTaskName#', req.Name);
        emailBody = emailBody.replace('#TaskCategory#', req.TaskCategory__c);
        emailBody = emailBody.replace('#DueDate#', String.valueOf(req.DueDate__c));
        emailBody = emailBody.replace('#OpportunityName#', req.Opportunity__r.Name);
        emailBody = emailBody.replace('#Requester#', String.valueOf(req.Requester__c));
        emailBody = emailBody.replace('#OwnerId#', ownerName);
        emailBody = emailBody.replace('依頼コメント：', commentTytle);
        emailBody = emailBody.replace('#TaskDetail#', comment);
        emailBody = emailBody.replace('SharePoint URL：', sharePointTytle);
        emailBody = emailBody.replace('#SharepointURL#', sharePoint);
        */

        //メールメッセージを設定
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setTargetObjectId(requestTaskId);
        mail.setTemplateId(template.Id);
        mail.setSubject(emailSubject);
        mail.setToAddresses(emailAddresses); // 宛先を設定
        mail.setCcAddresses(new List<String>{req.OwnerId}); // CCに所有者を追加
        mail.setHtmlBody(emailBody);

        //メール送信
        try {
            Messaging.sendEmail(new List <Messaging.SingleEmailMessage>{ mail });
            System.debug('メール送信成功');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'メール送信失敗しました。'));
            System.debug(e.getMessage() + e.getStackTraceString());
            return ;
        }
    }

    /**
     * メール本文のキーワードを置換
     */
    public static String replaceMessgae(String msg, String key, String str) {
        if (str == null) {
            str = '';
        }
        return msg.replace(key, str);
    }

    /**
     * 社内送信先1～10のメールアドレスを取得
     */
    public static List<String> getEmailAddressesList(RequestTask__c req) {
        // 社内送信先のリスト作成（有効な社内送信先のみ送信対象とする）
        List<String> emailAddresses = new List<String>();
        if(req.CompanyAddress01__c != null && req.CompanyAddress01__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress01__r.Mail__c);
        if(req.CompanyAddress02__c != null && req.CompanyAddress02__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress02__r.Mail__c);
        if(req.CompanyAddress03__c != null && req.CompanyAddress03__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress03__r.Mail__c);
        if(req.CompanyAddress04__c != null && req.CompanyAddress04__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress04__r.Mail__c);
        if(req.CompanyAddress05__c != null && req.CompanyAddress05__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress05__r.Mail__c);
        if(req.CompanyAddress06__c != null && req.CompanyAddress06__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress06__r.Mail__c);
        if(req.CompanyAddress07__c != null && req.CompanyAddress07__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress07__r.Mail__c);
        if(req.CompanyAddress08__c != null && req.CompanyAddress08__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress08__r.Mail__c);
        if(req.CompanyAddress09__c != null && req.CompanyAddress09__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress09__r.Mail__c);
        if(req.CompanyAddress10__c != null && req.CompanyAddress10__r.IsActive__c)
            emailAddresses.add(req.CompanyAddress10__r.Mail__c);
        System.debug(emailAddresses);
        return emailAddresses;
    }

    /**
     * 依頼先通知者1～4のメールアドレスを取得
     */
    public static List<String> getRequestNotificationList(RequestTask__c req) {
        // 社内送信先のリスト作成（有効な社内送信先のみ送信対象とする）
        List<String> emailAddresses = new List<String>();
        if(req.RequestNotification1__c != null)
            emailAddresses.add(req.RequestNotification1__c);
        if(req.RequestNotification2__c != null)
            emailAddresses.add(req.RequestNotification2__c);
        if(req.RequestNotification3__c != null)
            emailAddresses.add(req.RequestNotification3__c);
        if(req.RequestNotification4__c != null)
            emailAddresses.add(req.RequestNotification4__c);
        System.debug(emailAddresses);
        return emailAddresses;
    }

    /**
     * 依頼タスクの取得
     */
    public static List<RequestTask__c> getRequestTaskRecord(List<Id> requestTaskIds) {
        return [ SELECT Id
                , Name
                , Status__c
                , TaskCategory__c
                , DueDate__c
                , Requester__c
                , TaskDetail__c
                , CompanyAddress01__r.Mail__c
                , CompanyAddress02__r.Mail__c
                , CompanyAddress03__r.Mail__c
                , CompanyAddress04__r.Mail__c
                , CompanyAddress05__r.Mail__c
                , CompanyAddress06__r.Mail__c
                , CompanyAddress07__r.Mail__c
                , CompanyAddress08__r.Mail__c
                , CompanyAddress09__r.Mail__c
                , CompanyAddress10__r.Mail__c
                , CompanyAddress01__r.IsActive__c
                , CompanyAddress02__r.IsActive__c
                , CompanyAddress03__r.IsActive__c
                , CompanyAddress04__r.IsActive__c
                , CompanyAddress05__r.IsActive__c
                , CompanyAddress06__r.IsActive__c
                , CompanyAddress07__r.IsActive__c
                , CompanyAddress08__r.IsActive__c
                , CompanyAddress09__r.IsActive__c
                , CompanyAddress10__r.IsActive__c
                , SkipRequestApproval__c
                , RequestNotification1__c
                , RequestNotification2__c
                , RequestNotification3__c
                , RequestNotification4__c
                , Opportunity__r.Name
                , OwnerId
                , Owner.Name
                , SharePoint_URL__c
            FROM RequestTask__c
            WHERE Id IN :requestTaskIds];
    }
}