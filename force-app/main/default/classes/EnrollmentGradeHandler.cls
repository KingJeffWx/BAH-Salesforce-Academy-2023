public with sharing class EnrollmentGradeHandler {
    public static void updateAllEnrollmentGrades(List<Graded_Item__c> newGradedItems, List<Graded_Item__c> oldGradedItems, String operation) {
        // SOQL query to get all the grade categories
        List<Graded_Item_Category__c> categories = [SELECT Id, Weight__c, Course__c, Course__r.Name FROM Graded_Item_Category__c];

        // SOQL query to get all the course enrollments
        List<Course_Enrollment__c> courseEnrollments = [SELECT Id, Course__c, Student__c, Course__r.Name FROM Course_Enrollment__c];

        // SOQL query to get all the existing graded items
        List<Graded_Item__c> gradedItems = [SELECT Id, Course_Enrollment__c, Graded_Item_Category__c, Graded_Item_Category__r.Weight__c, Percent_Score__c FROM Graded_Item__c];

        // Holds all the course enrollments that need to be updated
        Set<Id> targetEnrollmentIds = new Set<Id>();

        // Holds all the IDs of the newGradedItems
        Set<Id> newGradedItemsIds = new Set<Id>();

        // Map a particular enrollment to the related graded item categories
        Map<Id, List<Id>> enrollmentToCategories = new Map<Id, List<Id>>();

        for (Graded_Item__c gradedItem : newGradedItems) {
            List<Id> relatedCategories = new List<Id>();

            // Save the target enrollment ID
            Id targetEnrollmentId = gradedItem.Course_Enrollment__c;

            for (Graded_Item_Category__c category : categories) {
                // Save only the related categories (that have the same course as the gradedItem)
                if (category.Id == gradedItem.Graded_Item_Category__c) {
                    relatedCategories.add(category.Id);
                }
            }

            targetEnrollmentIds.add(targetEnrollmentId);
            enrollmentToCategories.put(targetEnrollmentId, relatedCategories);
            newGradedItemsIds.add(gradedItem.Id);
        }

        // Update all the enrollments
        performGradeUpdates(targetEnrollmentIds, newGradedItemsIds, enrollmentToCategories, categories, courseEnrollments, gradedItems, newGradedItems, oldGradedItems, operation);

    }

    private static void performGradeUpdates(
        Set<Id> targetEnrollmentIds, 
        Set<Id> newGradedItemsIds,
        Map<Id, List<Id>> enrollmentToCategories, 
        List<Graded_Item_Category__c> categories, 
        List<Course_Enrollment__c> courseEnrollments,
        List<Graded_Item__c> gradedItems,
        List<Graded_Item__c> newGradedItems,
        List<Graded_Item__c> oldGradedItems,
        String operation) {

        List<Course_Enrollment__c> updatedCourseEnrollments = new List<Course_Enrollment__c>();
        
        for (Course_Enrollment__c ce : courseEnrollments) {
            if (targetEnrollmentIds.contains(ce.Id)) {
                // get the list of grade categories
                List<Id> relatedCategories = enrollmentToCategories.get(ce.Id);

                // get the target course for sum of weights calculation
                String targetCourse = '';
                for (Course_Enrollment__c courseEnrollment : courseEnrollments) {
                    if (targetEnrollmentIds.contains(courseEnrollment.Id)) {
                        targetCourse = courseEnrollment.Course__r.Name;
                    }
                }
                system.debug('Target course: ' + targetCourse);

                // what's the sum of all weights?
                Decimal sumWeights = 0;
                for (Graded_Item_Category__c gic : categories) {
                    // don't count a category if there's no graded items associated with it
                    Boolean categoryCounts = false;
                    for (Graded_Item__c gi : gradedItems) {
                        if (gic.Course__r.Name == targetCourse && gi.Course_Enrollment__c == ce.Id) {
                            categoryCounts = true;
                        }
                    }
                    if (gic.Course__r.Name == targetCourse && categoryCounts) {
                        sumWeights += gic.Weight__c;
                    }
                }
                system.debug('Sum of weights: ' + sumWeights);

                // calculate overall grade for this enrollment
                Decimal overallScore = 0;
                for (Graded_Item__c gi : gradedItems) {
                    if (gi.Course_Enrollment__c == ce.Id) {
                        system.debug('% score: ' + gi.Percent_Score__c);
                        system.debug('Weight: ' + gi.Graded_Item_Category__r.Weight__c);
                        Decimal itemScore = gi.Percent_Score__c * (gi.Graded_Item_Category__r.Weight__c / sumWeights);
                        system.debug('Item score: ' + itemScore);
                        overallScore += itemScore;
                    }
                }
                system.debug('Overall score: ' + overallScore);

                // handle insert case
                /*
                if (operation == 'insert') {
                    for (Id id : newGradedItemsIds) {
                        // find the correct graded item
                        for (Graded_Item__c gi : gradedItems) {
                            if (gi.Id == id) {
                                Decimal itemScore = gi.Percent_Score__c * (gi.Graded_Item_Category__r.Weight__c / sumWeights);
                                overallScore += itemScore;
                            }
                        }
                    }
                }
                
                // handle update case
                if (operation == 'update') {
                    for (Graded_Item__c gi : gradedItems) {
                        if (gi.Course_Enrollment__c == ce.Id) {
                            for (Integer i = 0; i < newGradedItems.size(); i++) {
                                // when newGradedItem and oldGradedItem differ...
                                if (oldGradedItems[i].Percent_Score__c != newGradedItems[i].Percent_Score__c) {
                                    Decimal oldItemScore = oldGradedItems[i].Percent_Score__c * (gi.Graded_Item_Category__r.Weight__c / sumWeights);
                                    Decimal newItemScore = newGradedItems[i].Percent_Score__c * (gi.Graded_Item_Category__r.Weight__c / sumWeights);
                                    overallScore -= oldItemScore;
                                    overallScore += newItemScore;
                                }
                            }
                        }
                    }
                }
                */
                ce.Overall_Score__c = overallScore;
                updatedCourseEnrollments.add(ce);
                
            }
        }
        update updatedCourseEnrollments;        
    }
}