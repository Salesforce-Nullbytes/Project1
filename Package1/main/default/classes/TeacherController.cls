public without sharing class TeacherController {

       // Inserts a new teacher into Salesforce with the teacher name and teacher email from the experience site

    @AuraEnabled
    public static void insertNewTeacher(String teacherName, String teacherEmail) {

        try {
            Teacher__c teacher = new Teacher__c();
            teacher.Name = teacherName;
            teacher.Teacher_Email__c = teacherEmail;

            insert teacher;
        }
        catch (Exception ex) {
            System.debug('An Exception Occured');
        }
    }
}
