public class DataFactory {
    public static void CreateAgency() {
        Agency__c agency1 = new Agency__c(name = 'Realty Agency 1');
        agency1.Phone_Number__c = '456 777-2323';
        agency1.Email_Address__c = 'realtyagency1@fakemaildomain.com';
        agency1.Address__c = '123 Realty Agency Road';
        agency1.City__c = 'Reston';
        agency1.State__c = 'VA';
        agency1.Zip_Code__c = '13345';
        Insert agency1;
    }
    public static void CreateInternalUsers() {
        User[] internalUsers = new User[]{};
        User realtor1 = MakeUser('Realtor', 1, 'Realty Agency 1');
        internalUsers.add(realtor1);
        User realtor2 = MakeUser('Realtor', 2, 'Realty Agency 1');
        internalUsers.add(realtor2);
        Insert internalUsers;
    }
    public static void CreateAll() {
        Realtor__c[] realtors = [SELECT id FROM Realtor__c];
        if (realtors.size() < 2) {
            System.debug('Must have at least 2 realtor objects!');
            return;
        }

        Account[] newAccounts = new List<Account>();
        for (Integer i = 1; i <= 10; i++) {
            Account a = new Account();
            a.name = 'Account ' + i;
            a.Primary_Phone_Number__c = '1112223333';
            a.Primary_Email__c = 'account' + i + '@fakemail.com';

            if (Math.mod(i,2) == 1) {
                a.Realtor__c = realtors[0].id;
            } else {
                a.Realtor__c = realtors[1].id;
            }

            newAccounts.add(a);
        }
        Insert newAccounts;

        Contact[] newContacts = new List<Contact>();
        for (Integer i = 0; i < newAccounts.size(); i++) {
            Contact c = new Contact();
            c.firstName = 'Some';
            c.lastName = 'Contact' + i;
            c.AccountId = newAccounts[i].id;
            c.phone = newAccounts[i].Primary_Phone_Number__c;
            c.email = c.lastName + newAccounts[i].Primary_Email__c;
            newContacts.add(c);
        }
        Insert newContacts;

        Property__c[] newProperties = new List<Property__c>();
        String[] addresses = new String[]{
            '2764 Fake Street',
            '47629 City Town',
            '234 Notrealville Road',
            '654 Road Street',
            '2634 Mountain Valley Court',
            '785 River Road',
            '945 Forest Drive',
            '534 Lakewood Lane',
            '1742 Longway Road',
            '26 Pinewood Blvd.'
        };
        for (Integer i = 0; i < newAccounts.size(); i++) {
            Property__c p = new Property__c();
            p.Property_Owner__c = newAccounts[i].id;
            p.Address__c = addresses[i];
            p.City__c = 'Reston';
            p.State__c = 'VA';
            p.Zip_Code__c = '13245';
            p.Status__c = 'Listed';
            p.List_Price__c = 200000 + 15000*i;
            newProperties.add(p);
        }
        Insert newProperties;

        Prospect__c[] newProspects = new List<Prospect__c>();
        
        newProspects.add(MakeProspect(newAccounts[0].id, newProperties[3].id));
        newProspects.add(MakeProspect(newAccounts[0].id, newProperties[5].id));
        newProspects.add(MakeProspect(newAccounts[4].id, newProperties[3].id));
        newProspects.add(MakeProspect(newAccounts[4].id, newProperties[5].id));
        newProspects.add(MakeProspect(newAccounts[6].id, newProperties[5].id));
        newProspects.add(MakeProspect(newAccounts[9].id, newProperties[2].id));
        newProspects.add(MakeProspect(newAccounts[4].id, newProperties[7].id));
        newProspects.add(MakeProspect(newAccounts[3].id, newProperties[4].id));

        Insert newProspects;
    }
    public static Prospect__c MakeProspect(ID acctId, ID propertyId){
        Prospect__c p = new Prospect__c();
        p.Account__c = acctId;
        p.Property__c = propertyId;
        p.Status__c = 'Favorited';
        return p;
    }
    public static User MakeUser(String type, Integer baseNum , String entity) {
        User newUser = new User();
        newUser.User_Category__c = type;
        newUser.Alias = 'user' + baseNum;
        newUser.CommunityNickname = type + newUser.Alias;
        newUser.email = newUser.CommunityNickname + '@fakemail.com';
        newUser.phone = '111-222-4443';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/Los_Angeles';
        newUser.Username = newUser.CommunityNickname + Math.random() * 100000 + '@fakemaildomain' + Math.random() * 100000 + '.com';
        newUser.firstName = type;
        newUser.lastName = 'User' + baseNum;
        newUser.Entity_Affiliation__c = entity;

        return newUser;
    }
}
