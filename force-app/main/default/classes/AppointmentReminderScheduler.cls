public with sharing class AppointmentReminderScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AppointmentReminderBatch(), 200);
    }
}