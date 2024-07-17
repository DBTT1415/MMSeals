@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    static void testPreventAccountDeletionWithActiveContracts() {
        // Create test data
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;
        
        // Create a valid Contract with 'Activated' status
        Contract activeContract = new Contract(
            AccountId = acc1.Id, 
            Status = 'Draft', 
            StartDate = Date.today(), 
            ContractTerm = 12,
            CustomerSignedDate = Date.today(),
            CompanySignedDate = Date.today(),
            SpecialTerms = 'Test Special Terms',
            BillingCity = 'Test City',
            BillingCountry = 'Test Country',
            BillingPostalCode = '12345',
            BillingState = 'Test State',
            BillingStreet = '123 Test Street',
            OwnerExpirationNotice = '30',
            Description = 'Test Contract Description'
        );
        insert activeContract;
			activeContract.Status ='Activated';
        update activeContract;
        // Attempt to delete the account
        Test.startTest();
        try {
            delete acc1;
            System.assert(false, 'Account deletion should have been prevented due to active contract.');
        } catch (DmlException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assert(e.getMessage().contains('Cannot delete an account whose Contract or Order is in Activated Status'), 'Expected error message not found');
        }
        Test.stopTest();
    }

    @isTest
    static void testPreventAccountDeletionWithActiveOrders() {
        // Create test data
        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;
        
        // Create a valid Contract with 'Activated' status
        Contract activeContract1 = new Contract(
            AccountId = acc2.Id, 
            Status = 'Draft', 
            StartDate = Date.today(), 
            ContractTerm = 12,
            CustomerSignedDate = Date.today(),
            CompanySignedDate = Date.today(),
            SpecialTerms = 'Test Special Terms',
            BillingCity = 'Test City',
            BillingCountry = 'Test Country',
            BillingPostalCode = '12345',
            BillingState = 'Test State',
            BillingStreet = '123 Test Street',
            OwnerExpirationNotice = '30',
            Description = 'Test Contract Description'
        );
        insert activeContract1;
			activeContract1.Status ='Activated';
        update activeContract1;
        
        // Create a valid Order with 'Activated' status
        Order activeOrder = new Order(
            AccountId = acc2.Id, 
            Status = 'Draft', 
            EffectiveDate = Date.today(),
            ContractId = [SELECT Id FROM Contract WHERE AccountId = :acc2.Id LIMIT 1].Id
            
                    );
        insert activeOrder;
        

        // Attempt to delete the account
        Test.startTest();
        try {
            delete acc2;
            System.assert(false, 'Account deletion should have been prevented due to active order.');
        } catch (DmlException e) {
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assert(e.getMessage().contains('Cannot delete an account whose Contract or Order is in Activated Status'), 'Expected error message not found');
        }
        Test.stopTest();
    }

    @isTest
    static void testAllowAccountDeletionWithoutActiveRecords() {
        // Create test data
        Account acc3 = new Account(Name = 'Test Account 3');
        insert acc3;
        
        Contract inactiveContract = new Contract(
            AccountId = acc3.Id, 
            Status = 'Draft', 
            StartDate = Date.today(), 
            ContractTerm = 12,
            CustomerSignedDate = Date.today(),
            CompanySignedDate = Date.today(),
            SpecialTerms = 'Test Special Terms',
            BillingCity = 'Test City',
            BillingCountry = 'Test Country',
            BillingPostalCode = '12345',
            BillingState = 'Test State',
            BillingStreet = '123 Test Street',
            OwnerExpirationNotice = '30',
            Description = 'Test Contract Description'
        );
        insert inactiveContract;

        Order inactiveOrder = new Order(
            AccountId = acc3.Id, 
            Status = 'Draft', 
            EffectiveDate = Date.today(),
            ContractId = inactiveContract.Id
            
        );
        insert inactiveOrder;

        // Attempt to delete the account
        Test.startTest();
        delete acc3;
        Test.stopTest();
        
        // Verify that the account was deleted
        List<Account> deletedAccounts = [SELECT Id FROM Account WHERE Id = :acc3.Id];
        System.assertEquals(0, deletedAccounts.size(), 'Account should be deleted');
    }
}