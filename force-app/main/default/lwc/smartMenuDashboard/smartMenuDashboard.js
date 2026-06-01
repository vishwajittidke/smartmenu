import { LightningElement, wire } from 'lwc';
import getRecentOrders from '@salesforce/apex/OrderService.getRecentOrders';

export default class SmartMenuDashboard extends LightningElement {
    orders;
    error;
    isLoading = true;

    columns = [
        { label: 'Order Name', fieldName: 'Name', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Total', fieldName: 'Total__c', type: 'currency' }
    ];


    @wire(getRecentOrders)
    wiredOrders({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.orders = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.orders = undefined;
            console.error('Error loading orders:', error);
        }
    }

    get hasOrders() {
        return this.orders && this.orders.length > 0;
    }

    get hasError() {
        return !!this.error;
    }

    get errorMessage() {
        if (!this.error) return '';
        return this.error.body ? this.error.body.message : 'An unknown error occurred';
    }
}
