import { LightningElement, track, wire } from 'lwc';
import getAllRestaurantTasks from '@salesforce/apex/TaskController.getAllRestaurantTasks';
import updateTaskStatus from '@salesforce/apex/TaskController.updateTaskStatus';
import { loadScript } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/CHARTJS'; // ✅ Must match static resource name

export default class RestaurantTaskManager extends LightningElement {
    @track tasks = [];
    @track statusColumns = [
        { status: 'Not Started', tasks: [] },
        { status: 'In Progress', tasks: [] },
        { status: 'Completed', tasks: [] }
    ];

    @track selectedRestaurantId;
    @track restaurantOptions = [];
    chart;
    draggedTaskId;
    isChartJsInitialized = false; // ✅ Prevent loading multiple times

    // Wire method to fetch tasks
    @wire(getAllRestaurantTasks)
    wiredTasks({ data, error }) {
        if (data) {
            this.tasks = data;
            this.prepareRestaurantOptions(data); // ✅ Fixed
            this.filterTasks();
            this.loadChart();
        } else if (error) {
            console.error('Error fetching tasks:', error);
        }
    }

    // ✅ Helper to prepare restaurant options for dropdown
    prepareRestaurantOptions(data) {
        const uniqueRestaurants = new Map();

        data.forEach(task => {
            if (task.WhatId && task.What && task.What.Name) {
                uniqueRestaurants.set(task.WhatId, {
                    label: task.What.Name,
                    value: task.WhatId
                });
            }
        });

        this.restaurantOptions = Array.from(uniqueRestaurants.values());
    }

    // ✅ Filter tasks into status columns
    filterTasks() {
        this.statusColumns.forEach(col => (col.tasks = []));

        this.tasks.forEach(task => {
            if (!this.selectedRestaurantId || task.WhatId === this.selectedRestaurantId) {
                const col = this.statusColumns.find(c => c.status === task.Status);
                if (col) {
                    col.tasks.push(task);
                }
            }
        });

        this.updateChart();
    }

    // ✅ Chart.js loading
    loadChart() {
        if (this.isChartJsInitialized) {
            this.renderChart();
            return;
        }

        loadScript(this, CHARTJS)
            .then(() => {
                this.isChartJsInitialized = true;
                console.log('Chart.js loaded successfully:', window.Chart); // debug
                this.renderChart();
            })
            .catch(error => {
                console.error('Error loading Chart.js:', error);
            });
    }

    // ✅ Render chart
    renderChart() {
        const ctx = this.template.querySelector('.pieChart').getContext('2d');
        const counts = this.statusColumns.map(col => col.tasks.length);

        if (this.chart) {
            this.chart.destroy();
        }

        this.chart = new window.Chart(ctx, {
            type: 'pie',
            data: {
                labels: this.statusColumns.map(col => col.status),
                datasets: [
                    {
                        data: counts,
                        backgroundColor: ['#FF6384', '#FFCE56', '#36A2EB']
                    }
                ]
            }
        });
    }

    // ✅ Update chart when tasks change
    updateChart() {
        if (this.chart) {
            this.chart.data.datasets[0].data = this.statusColumns.map(col => col.tasks.length);
            this.chart.update();
        }
    }
}