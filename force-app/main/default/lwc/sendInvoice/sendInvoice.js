import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactRoleByOpportunityId from '@salesforce/apex/OpportunityContactRoleController.getContactRoleByOpportunityId';
import getInvoiceNumber from '@salesforce/apex/OpportunityContactRoleController.getInvoiceNumber';
import sendEmail from '@salesforce/apex/MailSenderClass.sendEmail';
import OPPORTUNITY_NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import getInvoice from '@salesforce/apex/InvoiceService.getPreview';

export default class SendEmailComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @track opportunityName;
    @track emailBody;
    @track emailSubject = '';
    @track recipientName = '';
    @track recipientEmail = '';
    @track invoiceNumber = '';

    @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_NAME_FIELD] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.opportunityName = getFieldValue(data, OPPORTUNITY_NAME_FIELD);
            this.getOpportunityContactRole(data.id)
                .then(() => {
                    this.emailBody = this.constructEmailBody();
                })
              
        } else if (error) {
            console.error('Error while retrieving Opportunity data:', error);
        }
    }

    getOpportunityContactRole(opportunityId) {
        return new Promise((resolve, reject) => {
            getContactRoleByOpportunityId({ opportunityId: opportunityId })
                .then(result => {
                    if (result) {
                        this.recipientName = result.Contact.Name;
                        this.recipientEmail = result.Contact.Email;
                        this.getInvoiceNumber(opportunityId)
                            .then(() => resolve())
                            .catch(error => reject(error));
                    }
                })
                .catch(error => reject(error));
        });
    }

    getInvoiceNumber(opportunityId) {
        return new Promise((resolve, reject) => {
            getInvoiceNumber({ opportunityId: opportunityId })
                .then(result => {
                    if (result) {
                        this.invoiceNumber = result;
                        this.emailSubject = this.invoiceNumber;
                        resolve();
                    }
                })
                .catch(error => reject(error));
        });
    }

    handleEmailBodyChange(event) {
        this.emailBody = event.target.value;
        console.log('emailBody:', this.emailBody);
    }

    sendEmail() {
        const emailFormat = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;

        if (this.recipientEmail.match(emailFormat) && this.emailSubject && this.recipientName && this.invoiceNumber) {
            let replacedBody = this.constructEmailBody();

            sendEmail({
                recipientEmail: this.recipientEmail,
                subject: this.emailSubject,
                body: replacedBody,
                opportunityId: this.recordId
            })
            .then(() => {
                this.showToast('Success', 'Email sent successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
        } else {
            this.showToast('Error', 'Enter all required fields', 'error');
        }
    }

    constructEmailBody() {
        return `Hi, ${this.recipientName}.
                Thank you for your order ${this.invoiceNumber}.
                Regards, Tyz Corporation. `;
    }

    @wire(getInvoice, { invoiceNumber: '$invoiceNumber' }) 
    fetchedInvoice({error, data}) {
        if(data) {
            console.log('data' + data);
        } else if (error) {
            console.error('Error fetching invoice:', error);
        }
    }

    handleGenerateInvoice() {
        console.log('Record ID:', this.recordId);
        console.log('Invoice Number:', this.invoiceNumber);
    
        if (this.recordId && this.invoiceNumber) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://yuahennohach-dev-ed.develop.lightning.force.com/apex/Opportunity_PDF?id=' + this.recordId
                }
            });
        } else {
            this.showToast('Error', 'Unable to generate invoice. Record ID or Invoice Number is missing.', 'error');
        }
    }
    

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}