public with sharing class LoanApplicationTriggerHandler {

    public static final Decimal MIN_SCORE = 30;
    public static final Decimal APPROVAL_LIMIT = 500000;

    public static void process(List<Loan_Application__c> loans) {
        for (Loan_Application__c loan : loans) {
            if (loan.Loan_Amount__c == null
                || loan.Loan_Amount__c <= 0
                || loan.Annual_Income__c == null) {
                continue;
            }

            // Score = income as a percentage of the loan amount, capped at 100
            Decimal score = (loan.Annual_Income__c / loan.Loan_Amount__c) * 100;
            if (score > 100) {
                score = 100;
            }
            loan.Eligibility_Score__c = score.setScale(0);

            // Decide only when the applicant submits
            if (loan.Status__c == 'Submitted') {
                if (score < MIN_SCORE) {
                    loan.Status__c = 'Rejected';
                } else if (loan.Loan_Amount__c > APPROVAL_LIMIT) {
                    loan.Status__c = 'Pending Approval';
                } else {
                    loan.Status__c = 'Approved';
                }
            }
        }
    }
}