trigger LoanApplicationTrigger on Loan_Application__c (before insert, before update) {
    LoanApplicationTriggerHandler.process(Trigger.new);
}