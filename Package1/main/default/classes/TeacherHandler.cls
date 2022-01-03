public class TeacherHandler {

    public static void AssignTeacherStatus (List<Teacher__c> teachers)  {
        for(Teacher__c newTeacher : teachers) {
            newTeacher.Status__c = 'Interviewing';
        }
    }
}
