public class StudentController {

    // Inserts a new student into Salesforce with the student name, parent name, and parent email from the experience site

    @AuraEnabled
    public static void insertNewStudent(String studentName, String parentName, String parentEmail) {

        try {
            Student__c student = new Student__c();
            student.Name = studentName;
            student.Parent_Name__c = parentName;
            student.Parent_Email__c = parentEmail;

            insert student;
        }
        catch (Exception ex) {
            System.debug('An Exception Occured');
        }
    }
}
