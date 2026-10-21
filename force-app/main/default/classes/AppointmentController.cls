public with sharing class AppointmentController {

    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> getUpcomingAppointments(String status) {
        String filterStatus = String.isBlank(status) ? 'All' : status;

        if (filterStatus == 'All') {
            return [
                SELECT Id, Name, Appointment_Date_Time__c, Status__c,
                       Patient__r.Name, Doctor__r.Name
                FROM Appointment__c
                WHERE Appointment_Date_Time__c >= :System.now()
                ORDER BY Appointment_Date_Time__c ASC
                LIMIT 100
            ];
        }
        return [
            SELECT Id, Name, Appointment_Date_Time__c, Status__c,
                   Patient__r.Name, Doctor__r.Name
            FROM Appointment__c
            WHERE Appointment_Date_Time__c >= :System.now()
            AND Status__c = :filterStatus
            ORDER BY Appointment_Date_Time__c ASC
            LIMIT 100
        ];
    }
}