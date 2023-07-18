trigger UpdateCourseEnrollmentNameCourse on Course__c (after update) {
    if (trigger.isBefore) {
                
    }

    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            CourseEnrollHandler.updateCourseEnrollonCourseChange(trigger.new);
        }
    }
}