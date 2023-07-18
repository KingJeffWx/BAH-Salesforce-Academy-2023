trigger SetInitialEnrollmentGrade on Course_Enrollment__c (before insert) {
    if (trigger.isBefore) {
        if (trigger.isInsert) {
        
        }                
    }
}