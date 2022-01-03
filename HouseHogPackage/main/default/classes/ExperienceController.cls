public without sharing class ExperienceController {

    // @AuraEnabled(cacheable=true)
    // public static User GetUser() {
    //     id userId = UserInfo.getUserId();
    //     User u = [select id, name, email, contactId, accountId from User where id = :userId];
    //     //id getContactId = u.contactId;
    //     return u;
    // }

    @AuraEnabled(cacheable=true)
    public static Account GetAccountFinancialData() {
        ID thisAccountId = CurrentAccount().id;

        Account RequiredData = [
            SELECT id, name, Annual_Income__c, Monthly_Debt_Payments__c, FICO__c, Birth_Date__c
            FROM Account WHERE id = :thisAccountId
        ];
        return RequiredData;
    }

    // Used to validate whether signed in.
    // Returns (error) if not signed in, o/w returns ID (data)
    @AuraEnabled(cacheable=true)
    public static ID UserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled(cacheable=true)
    public static List<Prospect__c> UserProspects() {
        id userId = UserInfo.getUserId();
        User u = [select id, accountId from User where id = :userId];
        id userAccountId = u.accountId;

        Prospect__c[] allProspects = [
            SELECT id, Status__c, Property__r.Address__c, Property__r.City__c, Property__r.State__c, 
                Property__r.Zip_Code__c, Property__r.Status__c, FORMAT(Property__r.List_Price__c)
            FROM Prospect__c 
            WHERE Account__c = :userAccountId
        ];

        return allProspects;
    }

    @AuraEnabled(cacheable=true)
    public static List<Property__c> AllListedProperties() {
        Property__c[] allListed = [
            SELECT id, Status__c, Address__c, City__c, State__c, Zip_Code__c, FORMAT(List_Price__c)
            FROM Property__c 
            WHERE Status__c = 'Listed'
        ];

        return allListed;
    }

    @AuraEnabled
    public static Boolean UpdatePersonalDetails(Double income, Double debt, Integer fico, Date dob) {
        ID thisAccountId = CurrentAccount().id;
        Account updates = new Account(id = thisAccountId);
        Boolean mustUpdate = false;

        Account currentData = [
            SELECT id, name, Annual_Income__c, Monthly_Debt_Payments__c, FICO__c, Birth_Date__c
            FROM Account WHERE id = :thisAccountId
        ];

        if (income != currentData.Annual_Income__c) {
            updates.Annual_Income__c = income;
            mustUpdate = true;
        }
        if (debt != currentData.Monthly_Debt_Payments__c) {
            updates.Monthly_Debt_Payments__c = debt;
            mustUpdate = true;
        }
        if (fico != currentData.FICO__c) {
            updates.FICO__c = fico;
            mustUpdate = true;
        }
        if (dob != currentData.Birth_Date__c) {
            updates.Birth_Date__c = dob;
            mustUpdate = true;
        }

        try {
            if (mustUpdate) {
                Update updates;
                return true;
            }
        } catch(Exception e) {
            throw new AuraHandledException('Could not apply updates!');
        }
        return false;
    }

    // OVERRIDE WITH ACTUAL USER ACCOUNT INFO
    private static Account CurrentAccount() {
        Account current = [SELECT id, name FROM Account WHERE name = 'Account 5'];
        if (current == null) { System.debug('Account not found!'); }
        return current;
    }
}
