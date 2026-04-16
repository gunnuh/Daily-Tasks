import { LightningElement, track } from 'lwc';
import getOppRecords from '@salesforce/apex/handleopportunitytrigger.getOppRecords';

export default class ParentFilterComp extends LightningElement {

    @track opportunities = [];
    @track allOpportunities = [];
    @track filter = [];

    @track pageSize = 9;
    pageNumber = 1;
    totalPages = 1;
    filteredData = [];

    showLeft = true;
    searchTerm = '';
    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.filter=[];
        this.pageNumber = 1;
        this.applySearch();
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber === this.totalPages;
    }

    get rightClass() {
        return this.showLeft ? 'right' : 'right full';
    }

    connectedCallback() {
        getOppRecords()
            .then(result => {
                this.allOpportunities = result ? [...result] : [];
                this.pageNumber = 1;
                this.applyFilter();
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleFilter(event) {
        this.filter = event.detail.selectedFilters || [];
        console.log('Filters received:', JSON.stringify(this.filter));
        this.searchTerm='';
        this.pageNumber=1;
        this.applyFilter();
    }

    applyFilter() {
        const validFilters = this.filter.filter(f => f.field && f.operator && f.value);
        console.log('Valid filters:', JSON.stringify(validFilters)); // ✅ yahan dekho
        console.log('Total data:', this.allOpportunities.length);

        let data;
        if (validFilters.length === 0) {
            data = [...this.allOpportunities];
        } else {
            data = this.allOpportunities.filter(opp =>
                validFilters.every(f => this.matchesFilter(opp, f))
            );
        }

        this.filteredData = data;
        this.pageNumber = 1;   
        this.totalPages = Math.max(1, Math.ceil(this.filteredData.length / this.pageSize));
        this.updatePagination();                                           
    }

    applySearch() {
        let data;
        if (!this.searchTerm || this.searchTerm.length < 3) {
            data = [...this.allOpportunities]; 
        } else {
            const term = this.searchTerm.toLowerCase();
            data = this.allOpportunities.filter(opp => {
                const accountName = String(opp.AccountName || '').toLowerCase();
                const stageName   = String(opp.StageName   || '').toLowerCase();
                return accountName.includes(term) || stageName.includes(term);
            });
        }
        this.filteredData = data;
        this.totalPages = Math.max(1, Math.ceil(this.filteredData.length / this.pageSize));
        this.updatePagination();
    }

    matchesFilter(opp, filterObj) {
        const { field, operator, value } = filterObj;
        const recordValue = String(opp[field] ?? '').toLowerCase();
        const inputValue  = String(value).toLowerCase();
        const numRecord   = Number(opp[field]);
        const numInput    = Number(value);

        switch (operator) {
            case 'equals':          return recordValue === inputValue;
            case 'notequal':        return recordValue !== inputValue;
            case 'contains':        return recordValue.includes(inputValue);
            case 'doesnotcontains': return !recordValue.includes(inputValue);
            case 'startswith':      return recordValue.startsWith(inputValue);
            case 'greaterthan':     return numRecord > numInput;
            case 'lessthan':        return numRecord < numInput;
            case 'greaterorequal':  return numRecord >= numInput;
            case 'lessorequal':     return numRecord <= numInput;
            default:                return true;
        }
    }

    updatePagination() {
        const start = (this.pageNumber - 1) * this.pageSize;
        const end   = start + this.pageSize;
        this.opportunities = this.filteredData.slice(start, end); //triggers re-render via @track
    }

    handleNext() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.updatePagination();
        }
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.updatePagination();
        }
    }

    toggleSidebar() {
        this.showLeft = !this.showLeft;
    }
}