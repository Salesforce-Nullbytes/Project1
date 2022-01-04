public class TeacherHandler {

    // When a teacher is inserted, set the status to interviewing
    public static void AssignTeacherStatus (List<Teacher__c> teachers)  {
        for(Teacher__c newTeacher : teachers) {
            newTeacher.Status__c = 'Interviewing';
        }
    }
}
