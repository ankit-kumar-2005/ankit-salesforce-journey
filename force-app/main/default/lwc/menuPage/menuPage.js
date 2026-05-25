import { LightningElement, track, wire, api } from 'lwc';
import getCategoryTypePickListValue from '@salesforce/apex/MenuPageController.getCategoryTypePickListValue';
import getFoodMenuList from '@salesforce/apex/MenuPageController.getFoodMenuList';

export default class MenuPage extends LightningElement {
    // Filters
    @track searchMenu = '';
    @track selectCategory = '';
    @track categoryOptions = [];
    @api restaurantId;
       @track cart = [];
    @track showCartPage = false;
    @track ShowAddtocartbutton = false;

    // Menu & Pagination
    @track menuList = [];
    @track currentPage = 1;
    pageSize = 12;

    // Modal
    @track isModalOpen = false;
    @track selectedItem = {};

    // Cart
    @track cart = [];

    connectedCallback() {
        // Restore cart and page from localStorage
        const savedCart = JSON.parse(localStorage.getItem('cart'));
        const savedPage = parseInt(localStorage.getItem('currentPage'), 10);

        if (savedCart) this.cart = savedCart;
        if (savedPage) this.currentPage = savedPage;

        this.loadCategoryOptions();
    }

    // ------------------ Filters ------------------
    handleSearchMenuChange(event) {
        this.searchMenu = event.target.value;
    }

    handleSearchCategoryChange(event) {
        this.selectCategory = event.target.value;
    }

    // ------------------ Home ------------------
    handleHomeClick() {
        this.dispatchEvent(new CustomEvent('navigatehome'));
    }


    // ------------------ Cart ------------------
    handleAddToCart() {
        this.ShowAddtocartbutton  = true;
    }

    // ------------------ Category Picklist ------------------
    loadCategoryOptions() {
        getCategoryTypePickListValue()
            .then(result => {
                this.categoryOptions = [{ label: 'All', value: '' },
                    ...result.map(item => ({ label: item, value: item }))
                ];
            })
            .catch(() => { this.categoryOptions = []; });
    }

    // ------------------ Menu List ------------------
    @wire(getFoodMenuList, { searchMenu: '$searchMenu', selectCategory: '$selectCategory', restaurantId: '$restaurantId' })
    wiredgetFoodMenuList({ error, data }) {
        if (data) {
            // Initialize quantity for menu items
            this.menuList = data.map(item => {
                const cartItem = this.cart.find(i => i.Id === item.Id);
                return { ...item, quantity: cartItem ? cartItem.quantity : 1 };
            });
        } else if (error) {
            this.menuList = [];
        }
    }

    // ------------------ Pagination ------------------
    get totalPages() {
        return Math.ceil(this.menuList.length / this.pageSize);
    }

    get paginatedMenu() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.menuList.slice(start, end);
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            localStorage.setItem('currentPage', this.currentPage);
        }
    }

    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            localStorage.setItem('currentPage', this.currentPage);
        }
    }

    get disablePrev() { return this.currentPage === 1; }
    get disableNext() { return this.currentPage === this.totalPages; }

    // ------------------ Modal ------------------
    handleOpenModal(event) {
        const itemId = event.currentTarget.dataset.id;
        this.selectedItem = this.menuList.find(i => i.Id === itemId);
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    addToCart() {
        const itemId = this.selectedItem.Id;

        // Update menuList
        this.menuList = this.menuList.map(item => {
            if (item.Id === itemId) {
                const qty = item.quantity ? item.quantity + 1 : 1;
                return { ...item, quantity: qty };
            }
            return item;
        });

        // Update cart
        const cartItem = this.cart.find(i => i.Id === itemId);
        if (cartItem) {
            cartItem.quantity += 1;
        } else {
            this.cart.push({ ...this.selectedItem, quantity: 1 });
        }

        localStorage.setItem('cart', JSON.stringify(this.cart));
        this.isModalOpen = false;
    }

    // ------------------ Quantity ------------------
    handleIncrement(event) {
        const itemId = event.currentTarget.dataset.id;

        // Update menuList
        this.menuList = this.menuList.map(item => {
            if (item.Id === itemId) {
                const qty = item.quantity ? item.quantity + 1 : 1;
                return { ...item, quantity: qty };
            }
            return item;
        });

        // Update cart
        const cartItem = this.cart.find(i => i.Id === itemId);
        if (cartItem) {
            cartItem.quantity += 1;
        } else {
            const menuItem = this.menuList.find(i => i.Id === itemId);
            this.cart.push({ ...menuItem, quantity: 1 });
        }

        localStorage.setItem('cart', JSON.stringify(this.cart));
    }

    handleDecrement(event) {
        const itemId = event.currentTarget.dataset.id;

        // Update menuList
        this.menuList = this.menuList.map(item => {
            if (item.Id === itemId && item.quantity > 0) {
                return { ...item, quantity: item.quantity - 1 };
            }
            return item;
        });

        // Update cart
        const cartIndex = this.cart.findIndex(i => i.Id === itemId);
        if (cartIndex !== -1) {
            if (this.cart[cartIndex].quantity > 1) {
                this.cart[cartIndex].quantity -= 1;
            } else {
                this.cart.splice(cartIndex, 1); // Remove if 0
            }
        }

        localStorage.setItem('cart', JSON.stringify(this.cart));
    }

    // ------------------ Cart ------------------
    get cartCount() {
        return this.cart.reduce((sum, i) => sum + i.quantity, 0);
    }

  
     handleCartClick() {
        this.showCartPage = true;
    }

    // Handle Back from Cart
    handleBackFromCart() {
        this.showCartPage = false;
    }

    // Handle Order Completed
    handleOrderCompleted() {
        this.cart = []; // clear cart
        this.showCartPage = false; // go back to menu
        // optionally show a success toast
    }
}