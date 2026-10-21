import { LightningElement, wire } from 'lwc';
import getUpcomingAppointments from '@salesforce/apex/AppointmentController.getUpcomingAppointments';

const COLUMNS = [
    { label: 'Appointment', fieldName: 'name' },
    { label: 'Patient', fieldName: 'patientName' },
    { label: 'Doctor', fieldName: 'doctorName' },
    { label: 'Date and Time', fieldName: 'dateTime', type: 'date',
      typeAttributes: { year: 'numeric', month: 'short', day: '2-digit',
                        hour: '2-digit', minute: '2-digit' } },
    { label: 'Status', fieldName: 'status' }
];

export default class AppointmentDashboard extends LightningElement {
    columns = COLUMNS;
    selectedStatus = 'All';
    rows;
    error;

    statusOptions = [
        { label: 'All', value: 'All' },
        { label: 'Scheduled', value: 'Scheduled' },
        { label: 'Confirmed', value: 'Confirmed' },
        { label: 'Completed', value: 'Completed' },
        { label: 'Cancelled', value: 'Cancelled' }
    ];

    @wire(getUpcomingAppointments, { status: '$selectedStatus' })
    wiredAppointments({ data, error }) {
        if (data) {
            this.rows = data.map(a => ({
                id: a.Id,
                name: a.Name,
                patientName: a.Patient__r ? a.Patient__r.Name : '',
                doctorName: a.Doctor__r ? a.Doctor__r.Name : '',
                dateTime: a.Appointment_Date_Time__c,
                status: a.Status__c
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.rows = undefined;
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }
}