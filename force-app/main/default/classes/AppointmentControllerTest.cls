@isTest
private class AppointmentControllerTest {

    @TestSetup
    static void setup() {
        Doctor__c doc = new Doctor__c(Name = 'Dr. Test', Active__c = true);
        insert doc;
        Patient__c pat = new Patient__c(Name = 'Test Patient');
        insert pat;
        insert new Appointment__c(
            Doctor__c = doc.Id, Patient__c = pat.Id,
            Appointment_Date_Time__c = System.now().addDays(3),
            Status__c = 'Scheduled'
        );
    }

    @isTest
    static void returnsAllUpcoming() {
        List<Appointment__c> result = AppointmentController.getUpcomingAppointments('All');
        System.assertEquals(1, result.size());
    }

    @isTest
    static void filtersByStatus() {
        System.assertEquals(1, AppointmentController.getUpcomingAppointments('Scheduled').size());
        System.assertEquals(0, AppointmentController.getUpcomingAppointments('Completed').size());
    }
}