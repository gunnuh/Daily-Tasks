import { LightningElement, track } from 'lwc';
import getRates from '@salesforce/apex/CurrencyRateController.getRates';

export default class CurrencyRateTable extends LightningElement {

    @track data = [];
    @track pagedData = [];
    @track error;

    pageSize = 10;
    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;

    columns = [
        { label: 'Currency', fieldName: 'currency' },
        { label: 'Currency Rate (USD)', fieldName: 'rate', type: 'number' }
    ];

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getRates()
        .then(result => {
            const parsed = JSON.parse(result);
            const rates = parsed.conversion_rates;

            this.data = Object.keys(rates).map((key, index) => ({
                id: index,
                currency: key,
                rate: rates[key]
            }));

            this.totalRecords = this.data.length;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

            this.updatePageData();
        })
        .catch(error => {
            this.error = error;
        });
    }

    updatePageData() {
        const start = (this.pageNumber - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.pagedData = this.data.slice(start, end);
    }

    handlePrevious() {
        if(this.pageNumber > 1) {
            this.pageNumber--;
            this.updatePageData();
        }
    }

    handleNext() {
        if(this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.updatePageData();
        }
    }

    get disablePrevious() {
        return this.pageNumber === 1;
    }

    get disableNext() {
        return this.pageNumber === this.totalPages;
    }
}