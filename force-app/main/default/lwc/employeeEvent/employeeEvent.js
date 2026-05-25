import { LightningElement, wire, track } from 'lwc';
import getTodayEvents from '@salesforce/apex/EmployeeEventsController.getTodayEvents';

const INTERVAL_MS = 3000;

export default class EmployeeEventsCarousel extends LightningElement {
    @track allEvents = [];
    currentIndex = 0;
    timer;

   @wire(getTodayEvents)
wiredEvents({ error, data }) {
    if (data) {
        // Add a display label for each event
        this.allEvents = data.map(emp => {
            return {
                ...emp,
                eventLabel: emp.eventType === 'Birthday' ? '🎂 Birthday' : '🏆 Work Anniversary'
            };
        });

        this.startAutoSlide();
    } else if (error) {
        console.error('Error fetching events:', error);
    }
}

    get hasEvents() {
        return this.allEvents.length > 0;
    }

    get carouselTransformStyle() {
        return `transform: translateX(-${this.currentIndex * 100}%); transition: transform 0.5s ease-in-out;`;
    }

    startAutoSlide() {
        if (this.allEvents.length > 1) {
            clearInterval(this.timer);
            this.timer = setInterval(() => {
                this.currentIndex = (this.currentIndex + 1) % this.allEvents.length;
            }, INTERVAL_MS);
        }
    }

    disconnectedCallback() {
        clearInterval(this.timer);
    }
}