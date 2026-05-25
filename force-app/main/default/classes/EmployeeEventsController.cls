public with sharing class EmployeeEventsController {
    
    public class EmployeeWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String eventType;
        @AuraEnabled public String imageHtml; // Added for rich text formatting
        
        public EmployeeWrapper(String name, String imageUrl, String eventType, String imageHtml) {
            this.name = name;
            this.imageUrl = imageUrl;
            this.eventType = eventType;
            this.imageHtml = imageHtml;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EmployeeWrapper> getTodayEvents() {
        Date today = Date.today();
        List<EmployeeWrapper> results = new List<EmployeeWrapper>();
        
        List<Employee__c> employees = [
            SELECT Name, Employee_Image__c, Date_of_Birth__c, Joining_Date__c
            FROM Employee__c
            WHERE Date_of_Birth__c != NULL OR Joining_Date__c != NULL
        ];
        
        for (Employee__c emp : employees) {
            String empImageUrl;
            String empImageHtml;
            
            if (String.isNotBlank(emp.Employee_Image__c)) {
                empImageUrl = emp.Employee_Image__c;
                // Create HTML for rich text component with proper styling
                empImageHtml = '<img src="' + emp.Employee_Image__c + '" alt="' + emp.Name + '" style="width: 150px; height: 150px; border-radius: 50%; object-fit: cover; border: 3px solid #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />';
            } else {
                empImageUrl = null;
                // Default avatar HTML
                empImageHtml = '<div style="width: 150px; height: 150px; border-radius: 50%; background: linear-gradient(45deg, #667eea 0%, #764ba2 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 48px; font-weight: bold; border: 3px solid #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">' + emp.Name.substring(0, 1).toUpperCase() + '</div>';
            }
            
            // Check for Birthday
            if (emp.Date_of_Birth__c != null && emp.Date_of_Birth__c.day() == today.day() && emp.Date_of_Birth__c.month() == today.month()) {
                results.add(new EmployeeWrapper(emp.Name, empImageUrl, 'Birthday', empImageHtml));
            }
            
            // Check for Work Anniversary
            if (emp.Joining_Date__c != null && emp.Joining_Date__c.day() == today.day() && emp.Joining_Date__c.month() == today.month()) {
                results.add(new EmployeeWrapper(emp.Name, empImageUrl, 'Anniversary', empImageHtml));
            }
        }
        
        return results;
    }
}