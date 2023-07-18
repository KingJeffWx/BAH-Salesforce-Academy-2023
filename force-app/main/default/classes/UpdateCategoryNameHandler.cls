public with sharing class UpdateCategoryNameHandler {

    public static void updateCategoryName(List<Graded_Item_Category__c> newCategories) {

        Set<Id> courseIds = new Set<Id>();
        Map<Id, Id> categoryToCourseMap = new Map<Id, Id>();

        for (Graded_Item_Category__c category : newCategories) {
            courseIds.add(category.Course__c);
            categoryToCourseMap.put(category.Id, category.Course__c);
        }

        List<Course__c> courses = [SELECT Id, Name FROM Course__c WHERE Id IN :courseIds];

        // Update all the relevant category names
        for (Graded_Item_Category__c category : newCategories) {
            for (Course__c course : courses) {
                if (course.Id == category.Course__c) {
                    category.Name = category.Name + ' (' + course.Name + ')';
                }
            }
        }
    }
}