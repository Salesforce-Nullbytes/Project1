public class TeacherController {

    @AuraEnabled
    public static void insertNewTeacher(String teacherName, String teacherEmail) {
        //Teacher__c teacher = new Teacher__c (Name = teacherName, Teacher_Email__c = teacherEmail);

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
