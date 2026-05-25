import { LightningElement, api, track } from 'lwc';
import createOrderWithDetails from '@salesforce/apex/CartController.createOrderWithDetails';

export default class CartPage extends LightningElement {
    @api cartItems = [];
    @track isPaymentOpen = false;
    @track paymentType = '';
    @track customerName = '';
    @track customerEmail = '';
    @track customerPhone = '';

    // Items with subtotal
    get cartItemsWithTotal() {
        return this.cartItems.map(item => ({
            ...item,
            total: item.Price__c * item.quantity
        }));
    }

    // Grand total
    get grandTotal() {
        return this.cartItems.reduce((sum, item) => sum + (item.Price__c * item.quantity), 0);
    }

    // Payment Options
    get paymentOptions() {
        return [
            { label: 'Debit Card', value: 'Debit Card' },
            { label: 'Credit Card', value: 'Credit Card' },
            { label: 'UPI', value: 'UPI' },
            { label: 'Net Banking', value: 'Net Banking' },
            { label: 'Cash on Delivery', value: 'COD' }
        ];
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('backtomenu'));
    }

    handlePayment() {
        this.isPaymentOpen = true;
    }

    closePayment() {
        this.isPaymentOpen = false;
    }

    handlePaymentTypeChange(event) {
        this.paymentType = event.target.value;
    }

    handleCustomerNameChange(event) {
        this.customerName = event.target.value;
    }

    handleCustomerEmailChange(event) {
        this.customerEmail = event.target.value;
    }

    handleCustomerPhoneChange(event) {
        this.customerPhone = event.target.value;
    }

    removeItem(event) {
        const itemId = event.target.dataset.id;
        this.cartItems = this.cartItems.filter(item => item.Id !== itemId);
    }


    submitPayment() {
        const payload = {
            customerName: this.customerName,
            customerEmail: this.customerEmail,
            customerPhone: this.customerPhone,
            paymentType: this.paymentType,
            grandTotal: this.grandTotal,
            items: this.cartItems.map(i => ({
                menuItemId: i.Id,        // Restaurant_Menu_Item__c Id
                quantity: i.quantity,
                subtotal: i.Price__c * i.quantity,
                spiceLevel: i.Spice_Level__c || null,
                customization: i.Customization__c || null
            }))
        };

        createOrderWithDetails({ orderWrapperJson: JSON.stringify(payload) })
            .then(result => {
                console.log('Order Created Successfully:', result);
                this.isPaymentOpen = false;
                this.dispatchEvent(new CustomEvent('ordercompleted'));
            })
            .catch(error => {
                console.error('Error creating order:', error);
            });
    }
}