Loan_Application__c loan = [SELECT Id FROM Loan_Application__c WHERE Name = 'LN-0005' LIMIT 1];
Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setObjectId(loan.Id);
Approval.ProcessResult result = Approval.process(req);
System.debug('Submitted: ' + result.isSuccess());