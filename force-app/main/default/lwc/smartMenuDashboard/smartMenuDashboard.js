import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getRecentOrders from '@salesforce/apex/OrderService.getRecentOrders';
import updateOrderStatus from '@salesforce/apex/OrderService.updateOrderStatus';

const COLUMNS = [
    { label: 'Order ID', fieldName: 'formattedOrderId', type: 'text', sortable: true },
    { label: 'Customer Name', fieldName: 'customerName', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'Status__c', type: 'text', cellAttributes: { class: { fieldName: 'statusClass' } } },
    { label: 'Total Price', fieldName: 'Total__c', type: 'currency', typeAttributes: { currencyCode: 'INR' } },
    { label: 'Selected Recipes', fieldName: 'recipesList', type: 'text', wrapText: true },
    { label: 'Order Date', fieldName: 'Order_Date__c', type: 'date', typeAttributes: { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' } },
    {
        type: 'button',
        typeAttributes: {
            label: 'Details',
            name: 'view_details',
            title: 'View Details',
            variant: 'brand',
            iconPosition: 'left'
        }
    }
];

export default class SmartMenuDashboard extends LightningElement {
    columns = COLUMNS;
    @track orders = [];
    @track filteredOrders = [];
    @track selectedOrder = {};
    @track searchKey = '';
    @track selectedStatus = 'All';
    @track showModal = false;
    @track isSaving = false;
    @track isLive = false;
    
    isLoading = true;
    error;
    wiredOrdersResult;
    subscription = {};

    statusOptions = [
        { label: 'All', value: 'All' },
        { label: 'New', value: 'New' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
        { label: 'Cancelled', value: 'Cancelled' }
    ];

    @wire(getRecentOrders)
    wiredOrders(result) {
        this.wiredOrdersResult = result;
        const { error, data } = result;
        this.isLoading = false;
        
        if (data) {
            this.orders = data.map(order => {
                let statusClass = 'slds-text-color_weak';
                if (order.Status__c === 'New') statusClass = 'status-new';
                else if (order.Status__c === 'In Progress') statusClass = 'status-in-progress';
                else if (order.Status__c === 'Completed') statusClass = 'status-completed';
                else if (order.Status__c === 'Cancelled') statusClass = 'status-cancelled';

                // Deterministic short Order ID in ORD-000000 format based on Salesforce ID hash
                let hash = 0;
                const recordId = order.Id || '';
                for (let i = 0; i < recordId.length; i++) {
                    hash = (hash << 5) - hash + recordId.charCodeAt(i);
                    hash |= 0;
                }
                const formattedOrderId = 'ORD-' + String(Math.abs(hash) % 1000000).padStart(6, '0');

                const items = order.Order_Items__r ? order.Order_Items__r.map(item => {
                    return {
                        Id: item.Id,
                        recipeName: item.Menu_Item__r ? item.Menu_Item__r.Name : '—',
                        quantity: item.Quantity__c || 1,
                        unitPrice: item.Unit_Price__c || 0
                    };
                }) : [];

                const recipesList = items.map(item => `${item.recipeName} (x${item.quantity})`).join(', ') || '—';

                return {
                    ...order,
                    formattedOrderId: formattedOrderId,
                    customerName: order.Customer__r ? order.Customer__r.Name : '—',
                    statusClass: `slds-text-title_bold ${statusClass}`,
                    items: items,
                    hasItems: items.length > 0,
                    recipesList: recipesList
                };
            });
            this.error = undefined;
            this.applyFilters();
        } else if (error) {
            this.error = error;
            this.orders = [];
            this.filteredOrders = [];
            console.error('Error loading orders:', error);
        }
    }

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        const statusCallback = (response) => {
            console.log('Real-time order status update received: ', response);
            this.showToast('Updated', 'Order list updated in real-time!', 'info');
            this.refreshData();
        };

        const placedCallback = (response) => {
            console.log('Real-time new order received: ', response);
            this.showToast('New Order', 'A new order has been placed!', 'success');
            this.refreshData();
        };

        subscribe('/event/Order_Status_Changed__e', -1, statusCallback).then(response => {
            console.log('Subscribed to status channel: ', response.channel);
            this.subscription.status = response;
            this.isLive = true;
        }).catch(err => {
            console.error('Error subscribing to status events: ', err);
        });

        subscribe('/event/Order_Placed__e', -1, placedCallback).then(response => {
            console.log('Subscribed to placed channel: ', response.channel);
            this.subscription.placed = response;
        }).catch(err => {
            console.error('Error subscribing to placed events: ', err);
        });
    }

    handleUnsubscribe() {
        if (this.subscription.status) {
            unsubscribe(this.subscription.status, response => {
                console.log('Unsubscribed status: ', response);
            });
        }
        if (this.subscription.placed) {
            unsubscribe(this.subscription.placed, response => {
                console.log('Unsubscribed placed: ', response);
            });
        }
    }

    registerErrorListener() {
        onError(error => {
            console.error('EMP API error: ', error);
        });
    }

    async refreshData() {
        this.isLoading = true;
        await refreshApex(this.wiredOrdersResult);
        this.isLoading = false;
    }

    get totalOrdersCount() {
        return this.orders.length;
    }

    get totalRevenue() {
        return this.orders
            .filter(o => o.Status__c === 'Completed')
            .reduce((sum, o) => sum + (o.Total__c || 0), 0);
    }

    get avgOrderValue() {
        if (this.orders.length === 0) return 0;
        const total = this.orders.reduce((sum, o) => sum + (o.Total__c || 0), 0);
        return total / this.orders.length;
    }

    get activeOrdersCount() {
        return this.orders.filter(o => ['New', 'In Progress'].includes(o.Status__c)).length;
    }

    get hasOrders() {
        return this.filteredOrders && this.filteredOrders.length > 0;
    }

    get hasError() {
        return !!this.error;
    }

    get errorMessage() {
        if (!this.error) return '';
        return this.error.body ? this.error.body.message : 'An unknown error occurred';
    }

    handleSearch(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.applyFilters();
    }

    handleStatusFilter(event) {
        this.selectedStatus = event.target.value;
        this.applyFilters();
    }

    applyFilters() {
        this.filteredOrders = this.orders.filter(order => {
            const matchesSearch = order.Name.toLowerCase().includes(this.searchKey);
            const matchesStatus = this.selectedStatus === 'All' || order.Status__c === this.selectedStatus;
            return matchesSearch && matchesStatus;
        });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view_details') {
            this.selectedOrder = row;
            this.showModal = true;
        }
    }

    closeModal() {
        this.showModal = false;
    }

    get isNewStatus() {
        return this.selectedOrder.Status__c === 'New';
    }

    get isInProgressStatus() {
        return this.selectedOrder.Status__c === 'In Progress';
    }

    get canCancel() {
        return ['New', 'In Progress'].includes(this.selectedOrder.Status__c);
    }

    handleStartPreparing() {
        this.updateStatus(this.selectedOrder.Id, 'In Progress');
    }

    handleComplete() {
        this.updateStatus(this.selectedOrder.Id, 'Completed');
    }

    handleCancel() {
        this.updateStatus(this.selectedOrder.Id, 'Cancelled');
    }

    updateStatus(orderId, newStatus) {
        this.isSaving = true;
        updateOrderStatus({ orderId: orderId, newStatus: newStatus })
            .then(updatedOrder => {
                this.showToast('Success', `Order marked as ${newStatus} successfully.`, 'success');
                this.showModal = false;
                this.refreshData();
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'DML execution failed', 'error');
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}
