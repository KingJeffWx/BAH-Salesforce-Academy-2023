trigger UpdateCourseEnrollmentNameStudent on Contact (after update) {
    if (trigger.isBefore) {
                
    }

    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            CourseEnrollHandler.updateCourseEnrollonStudentChange(trigger.new);
        }
    }

}