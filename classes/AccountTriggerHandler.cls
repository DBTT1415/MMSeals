public class AccountTriggerHandler{
        public static void delAccount(){
            List<Account> lstAccount = Trigger.old;
            Set<Id> accIds = new Set<Id>();
            for(Account a: lstAccount)
                accIds.add(a.Id);
            
            List<Account> lstAcc = [SELECT Id, Name,(SELECT Id, Status FROM Contracts WHERE Status = 'Activated'), 
                                    (SELECT Id, Status FROM Orders WHERE Status = 'Activated') FROM Account WHERE Id IN :accIds];   
            
            system.debug(lstAcc);
            Set<Id> accountIdsNotToDelete = new Set<Id>();
            
            for (Account acc : lstAcc) {
                if (acc.Contracts.size() > 0 || acc.Orders.size() > 0) {
                    accountIdsNotToDelete.add(acc.Id);
                }
            }  
            for(Account acc1:lstAccount) 
            {
                if(accountIdsNotToDelete.contains(acc1.Id))
                    acc1.addError('Cannot delete an account whose Contract or Order is in Activated Status');
            }
            
        }
        
    }