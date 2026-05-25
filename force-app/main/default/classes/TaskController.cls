public with sharing class TaskController {

    // Get task count grouped by restaurant (WhatId) and status
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getTasksByRestaurant() {
        return [
            SELECT WhatId, What.Name, Status, COUNT(Id) taskCount
            FROM Task
            WHERE What.Type = 'Restaurant__c'
            GROUP BY WhatId, What.Name, Status
        ];
    }

    // Fetch all tasks related to restaurants for drag-drop
    @AuraEnabled(cacheable=true)
    public static List<Task> getAllRestaurantTasks() {
        return [
            SELECT Id, Subject, Status, WhatId, What.Name
            FROM Task
            WHERE What.Type = 'Restaurant__c'
        ];
    }

    // Update task status
    @AuraEnabled
    public static void updateTaskStatus(Id taskId, String status) {
        Task t = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
        t.Status = status;
        update t;
    }
}