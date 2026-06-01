import { LightningElement, wire } from 'lwc';
import getRecentOrders from '@salesforce/apex/OrderService.getRecentOrders';

export default class SmartMenuDashboard extends LightningElement {
    orders = [];

    connectedCallback() {
        this.loadOrders();
    }

    loadOrders() {
        getRecentOrders()
            .then(data => { this.orders = data; })
            .catch(error => { this.orders = []; console.error(error); });
    }
}
