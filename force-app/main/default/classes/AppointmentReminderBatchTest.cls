@isTest
private class AppointmentReminderBatchTest {

    @TestSetup
    static void setup() {
        Doctor__c doc = new Doctor__c(Name = 'Dr. Test', Active__c = true);
        insert doc;
        Patient__c pat = new Patient__c(Name = 'Test Patient', Email__c = 'test@example.com');
        insert pat;

        insert new Appointment__c(
            Doctor__c = doc.Id,
            Patient__c = pat.Id,
            Appointment_Date_Time__c = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(12, 0, 0, 0)),
            Status__c = 'Scheduled'
        );
    }

    @isTest
    static void batchRunsSuccessfully() {
        Test.startTest();
        Database.executeBatch(new AppointmentReminderBatch(), 200);
        Test.stopTest();

        AsyncApexJob job = [
            SELECT Status, NumberOfErrors
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'AppointmentReminderBatch'
            LIMIT 1
        ];
        System.assertEquals('Completed', job.Status);
        System.assertEquals(0, job.NumberOfErrors);
    }

    @isTest
    static void schedulerQueuesTheBatch() {
        Test.startTest();
        String jobId = System.schedule('Test Reminder Job', '0 0 8 * * ?', new AppointmentReminderScheduler());
        Test.stopTest();

        CronTrigger ct = [SELECT CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 8 * * ?', ct.CronExpression);
    }
}