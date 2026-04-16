import { LightningElement, wire, track } from 'lwc';
import Accountrec from '@salesforce/apex/HandlerforLWc.Accountrec';
import RelatedOpportunities from '@salesforce/apex/HandlerforLWc.RelatedOpportunities';
import updateOpportunities from '@salesforce/apex/HandlerforLWc.updateOpportunities';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountInfoDemo extends LightningElement {
    @track selectedAccountId = '';
    @track opportunity = [];
    @track accounts;
    @track draftValues = []; // Tracks datatable edits
    showOpportunities = false;
    // Store the whole wired result here for refreshApex

    wiredOppResponse;
    columns2 = [
        { label: 'Account Id', fieldName: 'AccountId' }, 
        { label: 'Opportunity Name', fieldName: 'DisplayName' }, 
        { label: 'Stage', fieldName: 'StageName', editable: true },
        { label: 'Amount', fieldName: 'Amount', type: 'currency', editable: true }
    ];

    @wire(Accountrec)
    wireAccount({ error, data }) {
        if (data) {
            this.accounts = data.map(item => {
                return { 
                    ...item, 
                    btnLabel: '+', 
                    btnVariant: 'brand',
                    iconName: 'utility:add'
                };
            });
        }
    }
    @wire(RelatedOpportunities, { accountId: '$selectedAccountId' })
    wiredOpportunities(result) {
        this.wiredOppResponse = result; // Important: Capture the result object
        const { data, error } = result;
        if (data) {
            this.opportunity = data.map(opp => {
                let prefix = '';
                if (opp.StageName === 'Closed Won') prefix = 'Won ';
                else if (opp.StageName === 'Closed Lost') prefix = 'Lost ';
                return { ...opp, DisplayName: prefix + opp.Name };
            });
        } else {
            this.opportunity = [];
        }
    }
 
    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        updateOpportunities({ oppList: updatedFields })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated successfully',
                        variant: 'success'
                    })
                );
                this.draftValues = [];
                return refreshApex(this.wiredOppResponse);

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || 'Error updating records',
                        variant: 'error'
                    })
                );
            });
    }
 
    handleClick(event) {
        const accid = event.target.dataset.id;
        if (this.selectedAccountId === accid) {
            this.showOpportunities = !this.showOpportunities;
        } else {
            this.selectedAccountId = accid;
            this.showOpportunities = true;
        }
        this.accounts = this.accounts.map(acc => {
            let label = '+';
            let variant = 'brand';
            if (acc.Id === this.selectedAccountId && this.showOpportunities) {
                label = '-';
                variant = 'destructive';
            }
            return { ...acc, btnLabel: label, btnVariant: variant , iconName:  isActive ? 'utility:dash' : 'utility:add'};
        });
        if (!this.showOpportunities) {
            this.opportunity = [];
        }
    }
 
    get dynamicGridClass() {
        return `slds-grid slds-wrap slds-gutters ${this.showOpportunities ? '' : 'slds-grid_align-center'}`;
    }
 
    get dynamicColumnClass() {
        return `slds-col slds-size_1-of-1 ${this.showOpportunities ? 'slds-medium-size_4-of-12' : 'slds-medium-size_6-of-12'}`;
    }
}
 