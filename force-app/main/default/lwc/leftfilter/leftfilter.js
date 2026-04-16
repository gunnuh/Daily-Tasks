import { LightningElement, wire, track } from 'lwc';
import getOppFields from '@salesforce/apex/handleopportunitytrigger.getOppFields';
const OPERATORS = [
    { label: 'equals', value: 'equals' },
    { label: 'not equal to', value: 'notequal' },
    { label: 'less than', value: 'lessthan' },
    { label: 'greater than', value: 'greaterthan' },
    { label: 'less or equal', value: 'lessorequal' },
    { label: 'greater or equal', value: 'greaterorequal' },
    { label: 'contains', value: 'contains' },
    { label: 'does not contains', value: 'doesnotcontains' },
    { label: 'starts with', value: 'startswith' }
];

export default class Leftfilter extends LightningElement {
    @track filters = [];
    filterOption = OPERATORS;

    @wire(getOppFields)
    wiredOpportunityFields;

    get showApplyOne() {
        return this.filters.length === 1;
    }

    get showApplyAll() {
        return this.filters.length > 1;
    }
    get hasFilters() {
        return this.filters.length > 0;
    }

    handleAddFilter() {
        const newFilter = { id: Date.now(), field: '', operator: 'equals', value: '' };
        this.filters = [...this.filters, newFilter];
    }

    handleChange(event) {
        const index = Number(event.target.dataset.index);
        const name = event.target.name;
        const value = event.target.value;
        // ✅ map se naya array banao — direct mutation nahi
        this.filters = this.filters.map((f, i) =>
            i === index ? { ...f, [name]: value } : f
        );
    }

    handleRemove(event) {
        const index = Number(event.target.dataset.index);
        // ✅ filter se naya array banao — splice nahi
        this.filters = this.filters.filter((_, i) => i !== index);
        this.handleApply();
    }

    handleRemoveAll() {
        this.filters = [];
        this.handleApply();
    }

    handleApply() {
        const validFilters = this.filters.filter(f => f.field && f.operator && f.value);
        this.dispatchEvent(new CustomEvent('changefilter', {
            detail: { selectedFilters: validFilters }
        }));
    }
}