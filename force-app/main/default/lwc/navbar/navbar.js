import { LightningElement, api } from 'lwc';

export default class Navbar extends LightningElement {
    @api filters = [];

    filterLabelMap = {
        closedWon: 'Closed Won',
        closedLost: 'Closed Lost',
        amountGreater10k: 'Amount > 10k'
    };

    // Prepare filters with labels for template
    get filtersWithLabels() {
        return this.filters.map(f => ({
            key: f,
            label: this.filterLabelMap[f] || f
        }));
    }

    removeFilter(event) {
        const filterKey = event.target.dataset.key;
        this.dispatchEvent(new CustomEvent('removefilter', {
            detail: filterKey
        }));
    }
}