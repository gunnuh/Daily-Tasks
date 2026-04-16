import { LightningElement, api, wire, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/handleopportunitytrigger.getAccounts';

export default class Righttable extends LightningElement {
    _opportunities;
    @track tableData = [];
    accountOptions = [];

    @wire(getAccounts)
    wiredAccounts({ data, error }) {
        if (data) {
            try {
                this.accountOptions = data.map(acc => ({
                    label: acc.label,
                    value: acc.value
                }));
            } catch (e) {
                this.showToast('Error', 'Error processing accounts: ' + e.message, 'error');
            }
        } else if (error) {
            this.showToast('Error', 'Error fetching accounts: ' + error.body?.message, 'error');
        }
    }

    @api
    set opportunities(value) {
        this._opportunities = value;
        this.buildTableData();
    }
    get opportunities() {
        return this._opportunities;
    }

    buildTableData() {
        try {
            if (this._opportunities) {
                this.tableData = this._opportunities.map(opp => ({
                    ...opp,
                    isEditing: false,
                    isEditingAmount: false,
                    pendingAccountId: opp.AccountId,    // pending value store
                    pendingAmount: opp.Amount            // pending value store
                }));
            }
        } catch (e) {
            this.showToast('Error', 'Error building table: ' + e.message, 'error');
        }
    }

    handleEditClick(event) {
        try {
            const id = event.currentTarget.dataset.id;
            this.tableData = this.tableData.map(row => {
                if (row.Id === id) {
                    return { ...row, isEditing: true, pendingAccountId: row.AccountId };
                }
                return row;
            });
        } catch (e) {
            this.showToast('Error', 'Error opening edit mode: ' + e.message, 'error');
        }
    }

    handleAmountEditClick(event) {
        try {
            const id = event.currentTarget.dataset.id;
            this.tableData = this.tableData.map(row => {
                if (row.Id === id) {
                    return { ...row, isEditingAmount: true, pendingAmount: row.Amount };
                }
                return row;
            });
        } catch (e) {
            this.showToast('Error', 'Error opening amount edit: ' + e.message, 'error');
        }
    }

    handleCancel(event) {
        try {
            const id = event.currentTarget.dataset.id;
            const type = event.currentTarget.dataset.type;
            this.tableData = this.tableData.map(row => {
                if (row.Id === id) {
                    if (type === 'amount') {
                        return { ...row, isEditingAmount: false, pendingAmount: row.Amount };
                    }
                    return { ...row, isEditing: false, pendingAccountId: row.AccountId };
                }
                return row;
            });
        } catch (e) {
            this.showToast('Error', 'Error cancelling edit: ' + e.message, 'error');
        }
    }

    // sirf pending value store karo — save nahi karo abhi
    handleAccountChange(event) {
        try {
            const newAccountId = event.detail.value;
            const oppId = event.target.dataset.id;
            this.tableData = this.tableData.map(row => {
                if (row.Id === oppId) {
                    return { ...row, pendingAccountId: newAccountId };
                }
                return row;
            });
        } catch (e) {
            this.showToast('Error', 'Error selecting account: ' + e.message, 'error');
        }
    }

    // sirf pending value store karo — save nahi karo abhi
    handleAmountChange(event) {
        try {
            const newAmount = parseFloat(event.detail.value);
            const oppId = event.target.dataset.id;
            this.tableData = this.tableData.map(row => {
                if (row.Id === oppId) {
                    return { ...row, pendingAmount: newAmount };
                }
                return row;
            });
        } catch (e) {
            this.showToast('Error', 'Error entering amount: ' + e.message, 'error');
        }
    }

    // Save button click par actual updateRecord
    handleAccountSave(event) {
        try {
            const oppId = event.currentTarget.dataset.id;
            const row = this.tableData.find(r => r.Id === oppId);

            if (!row.pendingAccountId) {
                this.showToast('Error', 'Please select an account', 'error');
                return;
            }

            const selectedAccount = this.accountOptions.find(a => a.value === row.pendingAccountId);

            const fields = {
                Id: oppId,
                AccountId: row.pendingAccountId
            };

            updateRecord({ fields })
                .then(() => {
                    this.tableData = this.tableData.map(r => {
                        if (r.Id === oppId) {
                            return {
                                ...r,
                                AccountId: row.pendingAccountId,
                                AccountName: selectedAccount ? selectedAccount.label : r.AccountName,
                                isEditing: false
                            };
                        }
                        return r;
                    });
                    this.showToast('Success', 'Opportunity reparented successfully!', 'success');
                    this.dispatchEvent(new CustomEvent('reparent'));
                })
                .catch(error => {
                    const message =
                        error.body?.output?.errors?.[0]?.message ||
                        error.body?.output?.fieldErrors?.AccountId?.[0]?.message ||
                        error.body?.message ||
                        'Reparenting failed';
                    this.showToast('Error', message, 'error');
                });
        } catch (e) {
            this.showToast('Error', 'Unexpected error: ' + e.message, 'error');
        }
    }

    handleAmountSave(event) {
        try {
            const oppId = event.currentTarget.dataset.id;
            const row = this.tableData.find(r => r.Id === oppId);

            if (isNaN(row.pendingAmount) || !oppId) {
                this.showToast('Error', 'Invalid amount', 'error');
                return;
            }

            const fields = {
                Id: oppId,
                Amount: row.pendingAmount
            };

            updateRecord({ fields })
                .then(() => {
                    this.tableData = this.tableData.map(r => {
                        if (r.Id === oppId) {
                            return {
                                ...r,
                                Amount: row.pendingAmount,
                                isEditingAmount: false
                            };
                        }
                        return r;
                    });
                    this.showToast('Success', 'Amount updated successfully!', 'success');
                    this.dispatchEvent(new CustomEvent('reparent'));
                })
                .catch(error => {
                    const message =
                        error.body?.output?.errors?.[0]?.message ||
                        error.body?.message ||
                        'Amount update failed';
                    this.showToast('Error', message, 'error');
                });
        } catch (e) {
            this.showToast('Error', 'Unexpected error: ' + e.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}