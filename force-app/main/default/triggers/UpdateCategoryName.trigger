trigger UpdateCategoryName on Graded_Item_Category__c (before insert, before update) {

    if (trigger.isBefore) {
        if (trigger.isInsert) {
            UpdateCategoryNameHandler.updateCategoryName(trigger.new);
        }
        if (trigger.isUpdate) {
            UpdateCategoryNameHandler.updateCategoryName(trigger.new);
        }
                
    }
}