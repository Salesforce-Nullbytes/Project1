public class CaseController {

    @AuraEnabled
    public static void insertNewCase(String caseName, String caseEmail, String caseDescription) {

        try {
            Case newCase = new Case();
            newCase.SuppliedName = caseName;
            newCase.SuppliedEmail = caseEmail;
            newCase.Description = caseDescription;
            newCase.Subject = 'Question/Conern';

            insert newCase;
        }
        catch (Exception ex) {
            System.debug('An Exception Occured');
        }
    }
}