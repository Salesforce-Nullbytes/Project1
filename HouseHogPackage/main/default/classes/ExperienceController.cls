public with sharing class ExperienceController {

    @AuraEnabled(cacheable=true)
    public static User GetUser() {

        id userId = UserInfo.getUserId();
        User u = [select id, name, email, contactId, accountId from User where id = :userId];
        //id getContactId = u.contactId;

        return u;
    }

    // @AuraEnabled
    // public static Account GetAccountWithName(string name) {
    //     string filter = '%' + name + '%';
    //     return [SELECT name FROM Account WHERE name LIKE : filter LIMIT 1];
    // }
}
