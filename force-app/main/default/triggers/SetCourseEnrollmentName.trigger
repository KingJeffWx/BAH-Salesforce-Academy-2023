trigger SetCourseEnrollmentName on Course_Enrollment__c (before insert, before update) {

    if (trigger.isBefore) {
        if (trigger.isInsert) {
            CourseEnrollHandler.insertCourseEnrollName(trigger.new);
        }
        if (trigger.isUpdate) {
            CourseEnrollHandler.insertCourseEnrollName(trigger.new);
        }
                
    }

    if (trigger.isAfter) {
        
    }
}