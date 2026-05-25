import { LightningElement, track, wire } from 'lwc';
import getCuisineTypePicklistValue from '@salesforce/apex/RestaurantHomePageController.getCuisineTypePicklistValue';
import getRestaurantList from '@salesforce/apex/RestaurantHomePageController.getRestaurantList';

export default class RestaurantHomePage extends LightningElement {
    @track searchLocation = '';
    @track searchRestaurant = '';
    @track selectCuisine = '';
    @track isVegOnly = false;
    @track cuisineOptions = [];
    @track restaurantList = [];

    // Pagination
    @track currentPage = 1;
    pageSize = 12;

    // Child component
    @track selectedRestaurantId = null;

    connectedCallback() {
        this.loadFilteroptions();
    }

    handleSearchLocationChange(event) {
        this.searchLocation = event.target.value;
    }
    handleSearchRestaurantChange(event) {
        this.searchRestaurant = event.target.value;
    }
    handleSearchCuisineChange(event) {
        this.selectCuisine = event.target.value;
    }
    handleVegOnlyChange(event) {
        this.isVegOnly = event.target.checked;
    }

    // Cuisine picklist values
    loadFilteroptions() {
        getCuisineTypePicklistValue()
            .then(result => {
                this.cuisineOptions = [{ label: 'All', value: '' },
                ...result.map(cuisine => {
                    return { label: cuisine, value: cuisine };
                })];
            }).catch(error => {
                this.error = error;
                this.cuisineOptions = [];
            });
    }

    // Restaurant list from Apex
    @wire(getRestaurantList, {
        searchLocation: '$searchLocation',
        searchRestaurant: '$searchRestaurant',
        selectCuisine: '$selectCuisine',
        isVegOnly: '$isVegOnly'
    })
    wiredRestaurantList({ error, data }) {
        if (data) {
            this.restaurantList = data;
            this.currentPage = 1; // reset on new search
        } else if (error) {
            this.error = error;
            this.restaurantList = [];
        }
    }

    // Pagination helpers
    get totalPages() {
        return Math.ceil(this.restaurantList.length / this.pageSize);
    }
    get paginatedRestaurants() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.restaurantList.slice(start, end);
    }
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }
    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }
    get disablePrev() {
        return this.currentPage === 1;
    }
    get disableNext() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }

    // Restaurant click → show child menu page ,parent to child
    handleRestaurantClick(event) {
        this.selectedRestaurantId = event.currentTarget.dataset.id;
    }

    // Child navigates home
    handleNavigateHome() {
        this.selectedRestaurantId = null;
    }
}