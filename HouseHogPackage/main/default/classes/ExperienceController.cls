public with sharing class ExperienceController {

    @AuraEnabled(cacheable=true)
    public static Account GetAccount() {
        return [SELECT name FROM Account LIMIT 1];
    }

    @AuraEnabled
    public static Account GetAccountWithName(string name) {
        string filter = '%' + name + '%';
        return [SELECT name FROM Account WHERE name LIKE : filter LIMIT 1];
    }
}
