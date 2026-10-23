@isTest
private class LoanApplicationTriggerHandlerTest {

    private static Loan_Application__c makeLoan(Decimal amount, Decimal income, String status) {
        return new Loan_Application__c(
            Applicant_Name__c = 'Test Applicant',
            Loan_Amount__c = amount,
            Annual_Income__c = income,
            Status__c = status
        );
    }

    @isTest
    static void smallLoanWithGoodIncomeIsApproved() {
        Loan_Application__c loan = makeLoan(300000, 600000, 'Submitted');
        insert loan;
        loan = [SELECT Status__c, Eligibility_Score__c FROM Loan_Application__c WHERE Id = :loan.Id];
        System.assertEquals('Approved', loan.Status__c);
        System.assertEquals(100, loan.Eligibility_Score__c);
    }

    @isTest
    static void lowScoreIsRejected() {
        Loan_Application__c loan = makeLoan(1000000, 100000, 'Submitted');
        insert loan;
        loan = [SELECT Status__c, Eligibility_Score__c FROM Loan_Application__c WHERE Id = :loan.Id];
        System.assertEquals('Rejected', loan.Status__c);
        System.assertEquals(10, loan.Eligibility_Score__c);
    }

    @isTest
    static void largeLoanNeedsApproval() {
        Loan_Application__c loan = makeLoan(1000000, 2000000, 'Submitted');
        insert loan;
        loan = [SELECT Status__c FROM Loan_Application__c WHERE Id = :loan.Id];
        System.assertEquals('Pending Approval', loan.Status__c);
    }

    @isTest
    static void draftIsNotDecided() {
        Loan_Application__c loan = makeLoan(300000, 600000, 'Draft');
        insert loan;
        loan = [SELECT Status__c FROM Loan_Application__c WHERE Id = :loan.Id];
        System.assertEquals('Draft', loan.Status__c);
    }

    @isTest
    static void bulkInsertWorks() {
        List<Loan_Application__c> loans = new List<Loan_Application__c>();
        for (Integer i = 0; i < 200; i++) {
            loans.add(makeLoan(300000, 600000, 'Submitted'));
        }
        Test.startTest();
        insert loans;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Loan_Application__c WHERE Status__c = 'Approved']);
    }
}