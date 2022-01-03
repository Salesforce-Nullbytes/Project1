public class StudentHandler {
    
    public static void AssignStudentLevel (List<Student__c> students)  {
        for(Student__c newStudent : students) {
            newStudent.Student_Level__c = '1';
        }
    }
}
