
trigger TransactionTrigger on Transaction__c (before insert) {
    public static void handleTransaction(List<Transaction__c> transactions) {
        // Get the current date
        Date currentDate = Date.today();
        
        // Query for the transactions made on the current date
        List<Transaction__c> todaysTransactions = [SELECT Id FROM Transaction__c WHERE CreatedDate = :currentDate];
        
        // Initialize variables for credit limit and transaction count
        Decimal dailyCreditLimit = 50000;
        Integer maxTransactionsPerDay = 3;
        
        // Initialize counters for credit amount and transaction count
        Decimal totalCreditAmount = 0;
        Integer transactionCount = 0;
        
        // Loop through the transactions
        for (Transaction__c transaction : transactions) {
            // Check if credit amount exceeds the daily credit limit
            if (transaction.Credit_Amount__c > dailyCreditLimit) {
                transaction.addError('Your daily credit limit is exceeded.');
            } else {
                // Increment the credit amount counter
                totalCreditAmount += transaction.Credit_Amount__c;
                // Increment the transaction count
                transactionCount++;
            }
        }
        
        // Check if the total credit amount exceeds the daily credit limit
        if (totalCreditAmount > dailyCreditLimit) {
            for (Transaction__c transaction : transactions) {
                transaction.addError('Your daily credit limit is exceeded.');
            }
        }
        
        // Check if the transaction count exceeds the maximum transactions per day
        if (transactionCount + todaysTransactions.size() > maxTransactionsPerDay) {
            for (Transaction__c transaction : transactions) {
                transaction.addError('Transaction limit exceeded. You cannot perform more than 3 transactions in a day.');
            }
        }
        
        // Update the daily credit spent and transaction count for successful transactions
        for (Transaction__c transaction : transactions) {
            if (transaction.isUpdateable()) {
                transaction.Daily_Credit_Spent__c = totalCreditAmount;
                transaction.Transaction_Count__c = transactionCount;
            }
        }
    }
}
