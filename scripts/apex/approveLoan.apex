Loan_Application__c loan = [SELECT Id FROM Loan_Application__c WHERE Name = 'LN-0005' LIMIT 1];
ProcessInstanceWorkitem item = [
    SELECT Id FROM ProcessInstanceWorkitem
    WHERE ProcessInstance.TargetObjectId = :loan.Id
    LIMIT 1
];
Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
req.setWorkitemId(item.Id);
req.setAction('Approve');
req.setComments('Approved by manager');
Approval.ProcessResult result = Approval.process(req);
System.debug('Approved: ' + result.isSuccess());