import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getOppRecords from '@salesforce/apex/AccountOpportunitiesController.getOppRecords';
import getAccounts from '@salesforce/apex/AccountOpportunitiesController.getAccounts';
import getOpportunityProducts from '@salesforce/apex/AccountOpportunitiesController.getOpportunityProducts';

const columns = [
    { label: 'Opp Name', fieldName: 'OpportunityLink', type: 'url', 
      typeAttributes: { label: { fieldName: 'OpportunityName' }, target: '_blank' }
    },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
    { label: 'Amount', fieldName: 'Amount' },
    { label: 'View Products', type: 'button', initialWidth: 150, typeAttributes: { label: 'View Products', name: 'view_products', title: 'View Products' } }
];

export default class Datatable_relatedOpp extends LightningElement {
    opps = [];
    columns = columns;
    accounts = [];
    @api recordId;
    isModalOpen = false;
    selectedOpportunityProducts = [];
    oppId = '';
    currentPage = 1;
    pageSize = 10;
    searchKey = '';
    searchKeyTotalAmount = '';
    @wire(CurrentPageReference) pageRef;
    singleAccount = {};

    get isAccountDetailPage() {
        const urlPath = window.location.pathname;
        console.log('url: ' + urlPath);
        return urlPath.includes('/lightning/r/Account/');
    }

    get isSingleAccountPage() {
        return this.isAccountDetailPage && this.recordId;
    }
    
    connectedCallback() {
        if (this.isSingleAccountPage) {
            this.loadSingleAccount(this.recordId);
        } else {
            this.loadAccounts();
        }
    }
    
    async loadSingleAccount(accountId) {
        try {
            const accountData = await getAccounts({ id: accountId });
            const accountWithOpps = {
                ...accountData,
                opportunities: await this.loadOppsForAccount(accountId)
            };
            this.singleAccount = accountWithOpps;
        } catch (error) {
            console.error('Error loading the specific account:', error);
        }
    }

    async loadAccounts() {
        try {
            const accounts = await getAccounts();
            const accountsWithOppsPromises = accounts.map(async account => {
                const opportunities = await this.loadOppsForAccount(account.Id);
                const totalAmount = opportunities.reduce((total, opp) => total + opp.Amount, 0);
                const accountLabel = `${account.Name} - Total Amount: ${totalAmount}`;
                const totalClosedAmount = opportunities.reduce((total, opp) => total + opp.Amount, 0);
                return {
                    ...account,
                    opportunities,
                    totalClosedAmount,
                    accountLabel
                };
            });
            this.accounts = await Promise.all(accountsWithOppsPromises);
        } catch (error) {
            console.error('Error loading accounts with opportunities:', error);
        }
    }

    async loadOppsForAccount(accountId) {
        try {
            const opps = await getOppRecords({ id: accountId });
            return opps.map(opp => ({
                ...opp,
                OpportunityLink: 'https://yuahennohach-dev-ed.develop.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view',
                OpportunityName: opp.Name,
                CreatedDate: opp.CreatedDate,
                CloseDate: opp.CloseDate,
                Amount: opp.Amount
            }));
        } catch (error) {
            console.error('Error loading opportunities for account:', error);
            return [];
        }
    }

    handleAccordionClick(event) {
        const accountId = event.currentTarget.dataset.accountId;
        const account = this.accounts.find(acc => acc.Id === accountId);
        if (account) {
            console.log('Opportunities for selected account:', account.opportunities);
        }
    }
  
    async handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view_products') {
            try {
                console.log('Opportunity id:', row.Id);
                const result = await getOpportunityProducts({ oppId: row.Id });
                console.log('Opportunity Products:', result);
                this.selectedOpportunityProducts = result;
                this.openModal();
            } catch (error) {
                console.error('Error loading opportunity products:', error);
            }
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedOpportunityProducts = [];
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateAccounts();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateAccounts();
        }
    }

    updateAccounts() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = this.currentPage * this.pageSize;
        this.paginatedAccounts = this.accounts.slice(startIndex, endIndex);
    }

    get paginatedAccounts() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = this.currentPage * this.pageSize;
        return this.accounts.slice(startIndex, endIndex);
    }

    get totalPages() {
        return Math.ceil(this.accounts.length / this.pageSize);
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.filterAccounts();
    }

    filterAccounts() {
        if (this.searchKey || this.searchKeyTotalAmount) {
            this.accounts = this.accounts.filter(account => {
                const nameMatch = !this.searchKey || account.Name.toLowerCase().includes(this.searchKey.toLowerCase());
                const amountMatch = !this.searchKeyTotalAmount || account.totalClosedAmount >= parseFloat(this.searchKeyTotalAmount);
                return nameMatch && amountMatch;
            });
        } else {
            this.loadAccounts();
        }
    }

    get totalClosedAmount() {
        return this.opps.reduce((total, opp) => total + opp.Amount, 0);
    }
   
    handleSearchTotalAmountChange(event) {
        this.searchKeyTotalAmount = event.target.value;
        this.filterAccountsByTotalAmount();
    }


filterAccountsByTotalAmount() {
    if (this.searchKey || this.searchKeyTotalAmount) {
        this.accounts = this.accounts.filter(account => {
            const nameMatch = !this.searchKey || account.Name.toLowerCase().includes(this.searchKey.toLowerCase());
            const amountMatch = !this.searchKeyTotalAmount || account.totalClosedAmount >= parseFloat(this.searchKeyTotalAmount);
            return nameMatch && amountMatch;
        });
    } else {
        this.loadAccounts(); 
    }
}
handleSearchChange(event) {
    const searchValue = event.target.value.trim();
    const [searchName, searchAmount] = searchValue.split(' ');

    this.searchKey = searchName;
    this.searchKeyTotalAmount = searchAmount;

    this.filterAccounts();
}

}