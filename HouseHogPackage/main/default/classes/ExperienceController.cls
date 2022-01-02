public without sharing class ExperienceController {

    @AuraEnabled(cacheable=true)
    public static User GetUser() {

        id userId = UserInfo.getUserId();
        User u = [select id, name, email, contactId, accountId from User where id = :userId];
        //id getContactId = u.contactId;

        return u;
    }

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

    // @AuraEnabled
    // public static Account GetAccountWithName(string name) {
    //     string filter = '%' + name + '%';
    //     return [SELECT name FROM Account WHERE name LIKE : filter LIMIT 1];
    // }
}
