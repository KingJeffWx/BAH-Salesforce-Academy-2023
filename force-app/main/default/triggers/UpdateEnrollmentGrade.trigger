trigger UpdateEnrollmentGrade on Graded_Item__c (after insert, after update) {
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            EnrollmentGradeHandler.updateAllEnrollmentGrades(trigger.new, null, 'insert');
        }
        if (trigger.isUpdate) {
            EnrollmentGradeHandler.updateAllEnrollmentGrades(trigger.new, trigger.old, 'update');
        }
    }
}