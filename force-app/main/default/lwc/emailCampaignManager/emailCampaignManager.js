import { LightningElement, track, api } from 'lwc';
import runBatchApex from '@salesforce/apex/EmailCampaignManager.runBatch';
import scheduleBatchApex from '@salesforce/apex/EmailCampaignManager.scheduleBatch';
import cancelSchedulerApex from '@salesforce/apex/EmailCampaignManager.cancelScheduler';

export default class EmailCampaignManager extends LightningElement {
    @api identifier;
    @track cronString = '0 0 0 * * ? *'; 
    @track isSchedulerScheduled = false;
    @track errorMessage = ''; 

    handleCronStringChange(event) {
        this.cronString = event.target.value;
    }

    validateCronString(cronString) {
        const cronPattern = /^(\d{1,2}) (\d{1,2}) (\d{1,2}) ([\d*]{1,2}) ([\d*]{1,2}) ([\d?L#]{1,5}) (\d{4}|\*)$/;
        return cronPattern.test(cronString);
    }

    handleRunBatch() {
        runBatchApex({ batchClassName: 'BirthdayEmailBatch' })
            .then(result => {
                console.log('batch successfully' + result);
            })
            .catch(error => {
                console.error('Error batch' + error);
            });
    }

    handleScheduleBatch() {
        scheduleBatchApex({ schedulerClassName: 'BirthdayEmailScheduler', cronString: this.cronString })
            .then(result => {
                this.isSchedulerScheduled = true;
                this.template.querySelector('lightning-input').disabled = true;
                console.log('Batch scheduled successfully' + result);
            })
            .catch(error => {
                console.error('Error scheduling batch', error);
            });
    }

    handleCancelScheduler() {
        cancelSchedulerApex({ schedulerClassName: 'Birthday Email Scheduler' })
            .then(result => {
                this.isSchedulerScheduled = false;
                this.template.querySelector('lightning-input').disabled = false;
                console.log('Scheduler canceled successfully' + result);
            })
            .catch(error => {
                console.error('Error canceling scheduler', error);
            });
    }
}
