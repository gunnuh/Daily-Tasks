import { LightningElement, wire, api, track } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import relationshipModal from 'c/relationshipModal';

export default class ContactUserMatrix extends LightningElement {
    @api recordId;
    @track users = [];
    @track matrixRows = [];
    records = [];

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Relationship_Matrices__r',
        fields: [
            'Relationship_Matrix__c.ContactName__c',
            'Relationship_Matrix__c.ContactName__r.Name',
            'Relationship_Matrix__c.UserName__c',
            'Relationship_Matrix__c.UserName__r.Name',
            'Relationship_Matrix__c.Health_Index__c',
            'Relationship_Matrix__c.Id'
        ]
    })
    wiredData({ data, error }) {
        if (data) {
            this.records = data.records;
            this.matrix();
        } else if (error) {
            console.error(error);
        }
    }

    matrix() {
        const contacts = {};
        const users = {};
        const matrix = {};

        this.records.forEach(rec => {
            const cId = rec.fields.ContactName__c?.value;
            const cName = rec.fields.ContactName__r?.value?.fields?.Name?.value;
            const uId = rec.fields.UserName__c?.value;
            const uName = rec.fields.UserName__r?.value?.fields?.Name?.value;
            if(!cId) return;

            contacts[cId] = { id: cId, name: cName };
            //users[uId] = { id: uId, name: uName };
            if(uId){
                users[uId] = {id: uId, name:uName};
                if(!matrix[cId]) matrix[cId]={};
                matrix[cId][uId] = {
                    img: rec.fields.Health_Index__c.value,
                    id: rec.fields.Id.value
                };
            }

            /*if (!matrix[cId]) matrix[cId] = {};
            matrix[cId][uId] = {
                img: rec.fields.Health_Index__c.value,
                id: rec.fields.Id.value
            };*/
        });

        this.users = Object.values(users);
        this.matrixRows = Object.values(contacts).map(c => {
            const row = { id: c.id, name: c.name, cells: [] };
            this.users.forEach(u => {
                row.cells.push({
                    key: c.id + '_' + u.id,
                    entry: (matrix[c.id] && matrix[c.id][u.id]) ? matrix[c.id][u.id] : null
                });
            });
            return row;
        });
    }

    //modal return promise so handleClick is async
    async handleClick(event) {
        const recId = event.currentTarget.dataset.recid;
        const result = await relationshipModal.open({
            size: 'small',
            recordId: recId
        });
        console.log('Modal closed with:', result);
    }

}