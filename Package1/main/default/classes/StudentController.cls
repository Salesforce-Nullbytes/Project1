public class StudentController {

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
