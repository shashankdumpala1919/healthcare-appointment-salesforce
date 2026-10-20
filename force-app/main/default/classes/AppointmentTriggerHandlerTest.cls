@isTest
private class AppointmentTriggerHandlerTest {

    @TestSetup
    static void setup() {
        Doctor__c doc = new Doctor__c(Name = 'Dr. Test', Active__c = true);
        insert doc;
        Patient__c pat = new Patient__c(Name = 'Test Patient');
        insert pat;
    }

    @isTest
    static void singleBookingSucceeds() {
        Doctor__c doc = [SELECT Id FROM Doctor__c LIMIT 1];
        Patient__c pat = [SELECT Id FROM Patient__c LIMIT 1];

        Appointment__c appt = new Appointment__c(
            Doctor__c = doc.Id,
            Patient__c = pat.Id,
            Appointment_Date_Time__c = System.now().addDays(5),
            Status__c = 'Scheduled'
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(appt, false);
        Test.stopTest();

        System.assert(result.isSuccess(), 'First booking should succeed');
    }

    @isTest
    static void doubleBookingIsBlocked() {
        Doctor__c doc = [SELECT Id FROM Doctor__c LIMIT 1];
        Patient__c pat = [SELECT Id FROM Patient__c LIMIT 1];
        DateTime slot = System.now().addDays(5);

        insert new Appointment__c(
            Doctor__c = doc.Id, Patient__c = pat.Id,
            Appointment_Date_Time__c = slot, Status__c = 'Scheduled'
        );

        Appointment__c clash = new Appointment__c(
            Doctor__c = doc.Id, Patient__c = pat.Id,
            Appointment_Date_Time__c = slot, Status__c = 'Scheduled'
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(clash, false);
        Test.stopTest();

        System.assert(!result.isSuccess(), 'Double booking should be blocked');
        System.assert(
            result.getErrors()[0].getMessage().contains('already has an appointment'),
            'Error message should explain the clash'
        );
    }

    @isTest
    static void bulkInsertWorks() {
        Doctor__c doc = [SELECT Id FROM Doctor__c LIMIT 1];
        Patient__c pat = [SELECT Id FROM Patient__c LIMIT 1];

        List<Appointment__c> appts = new List<Appointment__c>();
        for (Integer i = 0; i < 200; i++) {
            appts.add(new Appointment__c(
                Doctor__c = doc.Id, Patient__c = pat.Id,
                Appointment_Date_Time__c = System.now().addDays(10).addMinutes(i * 30),
                Status__c = 'Scheduled'
            ));
        }

        Test.startTest();
        insert appts;
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Appointment__c WHERE Doctor__c = :doc.Id]);
    }
}