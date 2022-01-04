public class StudentHandler {
    
    // When a student is inserted, set the level to 1
    public static void AssignStudentLevel (List<Student__c> students)  {
        for(Student__c newStudent : students) {
            newStudent.Student_Level__c = '1';
        }
    }
}
