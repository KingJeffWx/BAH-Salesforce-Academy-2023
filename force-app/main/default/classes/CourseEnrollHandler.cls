public with sharing class CourseEnrollHandler {
    
    public static void insertCourseEnrollName(List<Course_Enrollment__c> cList) {
        Set<Id> studIds = new Set<Id>();
        Set<Id> coreIds = new Set<Id>();

        Map<Id, string> studFName = new Map<Id, String>();
        Map<Id, string> studLName = new Map<Id, String>();
        Map<Id, string> coreName = new Map<Id, String>();
        Map<Id, string> term = new Map<Id, String>();
        
        for (Course_Enrollment__c core : cList) {
            studIds.add(core.Student__c);
            coreIds.add(core.Course__c);
        }

        for (Contact con :[SELECT Id, FirstName, LastName FROM Contact WHERE Id IN :studIds]) {
            studFName.put(con.Id, con.FirstName);
            studLName.put(con.Id, con.LastName);
        }
        for (Course__c co :[SELECT Id, Name, Term__c FROM Course__c WHERE Id IN :coreIds]) {
            coreName.put(co.Id, co.Name);
            term.put(co.Id, co.Term__c);
        }

        for (Course_Enrollment__c core : cList) {
            core.Name = studFName.get(core.Student__c) + ' ' + studLName.get(core.Student__c) + ', ' +
            coreName.get(core.Course__c) + ', ' + term.get(core.Course__c);
        }
    }

    public static void updateCourseEnrollonStudentChange(List<Contact> cList) {
        Set<Id> cListIds = new Set<Id>();
        Map<Id, String> firstNames = new Map<Id, String>();
        Map<Id, String> lastNames = new Map<Id, String>();

        for (Contact c : cList) {
            cListIds.add(c.Id);
            firstNames.put(c.Id, c.FirstName);
            lastNames.put(c.Id, c.LastName);
        }
        
        // SOQL query to find related course enrollments
        List<Course_Enrollment__c> relatedEnrollments = [SELECT Id, Name FROM Course_Enrollment__c WHERE Student__c IN :cListIds];
            
        // for each related course enrollment
        for (Course_Enrollment__c ce : relatedEnrollments) {
            // update the course enrollment name
            String oldStudentName = ce.Name;
            String newStudentName = firstNames.get(ce.Id) + ' ' + lastNames.get(ce.Id);
            ce.Name = ce.Name.replace(oldStudentName, newStudentName);
        }
        system.debug(relatedEnrollments);
        update relatedEnrollments;
    }

    public static void updateCourseEnrollonCourseChange(List<Course__c> cList) {
        Set<Id> cListIds = new Set<Id>();
        Map<Id, String> courseNames = new Map<Id, String>();
        Map<Id, String> courseTerms = new Map<Id, String>();

        for (Course__c c : cList) {
            cListIds.add(c.Id);
            courseNames.put(c.Id, c.Name);
            courseTerms.put(c.Id, c.Term__c);
        }

        // SOQL query to find related course enrollments
        List<Course_Enrollment__c> relatedEnrollments = [SELECT Id, Name, Course__r.Term__c FROM Course_Enrollment__c WHERE Course__c IN :cListIds];
        
        // for each related course enrollment
        for (Course_Enrollment__c ce : relatedEnrollments) {
            // update the course enrollment name
            String oldCourseName = ce.Name;
            String oldCourseTerm = ce.Course__r.Term__c;
            String oldCourseInfo = oldCourseName + ', ' + oldCourseTerm;
            String newCourseInfo = courseNames.get(ce.Id) + ', ' + courseTerms.get(ce.Id);
            ce.Name = ce.Name.replace(oldCourseInfo, newCourseInfo);
        }
        update relatedEnrollments;
    }
}