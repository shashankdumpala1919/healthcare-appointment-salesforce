public with sharing class AppointmentTriggerHandler {

    public static void preventDoubleBooking(
        List<Appointment__c> newAppointments,
        Map<Id, Appointment__c> oldMap
    ) {
        // Step 1: collect doctor IDs and times from the records being saved
        Set<Id> doctorIds = new Set<Id>();
        Set<DateTime> times = new Set<DateTime>();

        for (Appointment__c appt : newAppointments) {
            if (appt.Doctor__c != null && appt.Appointment_Date_Time__c != null) {
                doctorIds.add(appt.Doctor__c);
                times.add(appt.Appointment_Date_Time__c);
            }
        }

        if (doctorIds.isEmpty()) {
            return;
        }

        // Step 2: ONE query for existing active appointments (outside any loop)
        Set<String> existingKeys = new Set<String>();
        for (Appointment__c existing : [
            SELECT Id, Doctor__c, Appointment_Date_Time__c
            FROM Appointment__c
            WHERE Doctor__c IN :doctorIds
            AND Appointment_Date_Time__c IN :times
            AND Status__c != 'Cancelled'
            AND Id NOT IN :newAppointments
        ]) {
            existingKeys.add(existing.Doctor__c + '|' + existing.Appointment_Date_Time__c.getTime());
        }

        // Step 3: check each record, also catching clashes inside the same batch
        Set<String> batchKeys = new Set<String>();
        for (Appointment__c appt : newAppointments) {
            if (appt.Doctor__c == null
                || appt.Appointment_Date_Time__c == null
                || appt.Status__c == 'Cancelled') {
                continue;
            }
            String key = appt.Doctor__c + '|' + appt.Appointment_Date_Time__c.getTime();
            if (existingKeys.contains(key) || batchKeys.contains(key)) {
                appt.addError('This doctor already has an appointment at this time.');
            } else {
                batchKeys.add(key);
            }
        }
    }
}