public with sharing class AppointmentReminderBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date tomorrow = Date.today().addDays(1);
        Datetime startOfDay = Datetime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
        Datetime endOfDay = startOfDay.addDays(1);

        return Database.getQueryLocator([
            SELECT Id, Name, Appointment_Date_Time__c,
                   Patient__r.Name, Patient__r.Email__c,
                   Doctor__r.Name
            FROM Appointment__c
            WHERE Appointment_Date_Time__c >= :startOfDay
            AND Appointment_Date_Time__c < :endOfDay
            AND Status__c IN ('Scheduled', 'Confirmed')
            AND Patient__r.Email__c != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Appointment__c> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Appointment__c appt : scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ appt.Patient__r.Email__c });
            mail.setSubject('Appointment reminder for tomorrow');
            mail.setPlainTextBody(
                'Hello ' + appt.Patient__r.Name + ', this is a reminder that you have appointment '
                + appt.Name + ' with ' + appt.Doctor__r.Name + ' on '
                + appt.Appointment_Date_Time__c.format() + '.'
            );
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Appointment reminder batch finished.');
    }
}