@isTest
public class EmployeeTriggerHandlerTest {
    
    @TestSetup
    static void setupData() {
        Employee__c empWithDate = TestDataFactory.createEmployee(
            'Emp With Date',
            Date.newInstance(2025, 8, 1),
            false,
            'Confirmed',
            Date.newInstance(2000, 1, 1),
            '9999999999',
            '1234 5678 9101',
            'Test Address',
            'Jaipur',
            'ABCDE1234F',
            'Hybrid',
            2,
            'Core Delivery'
        );
        
        Employee__c empWithLateDate = TestDataFactory.createEmployee(
            'Emp With Late Date',
            Date.newInstance(2025, 8, 20),
            false,
            'Confirmed',
            Date.newInstance(2000, 2, 2),
            '8888888888',
            '4321 8765 1091',
            'Test Address 2',
            'Delhi',
            'FGHIJ5678K',
            'Remote',
            5,
            'Core Delivery'
        );
        
        Employee__c empWithoutDate = TestDataFactory.createEmployee(
            'Emp Without Date',
            null,
            false,
            'Probation',
            Date.newInstance(2001, 3, 3),
            '7777777777',
            '5678 1234 0912',
            'Test Address 3',
            'Mumbai',
            'KLMNO9012P',
            'Onsite',
            1,
            'Core Delivery'
        );
        
        insert new List<Employee__c>{ empWithDate, empWithLateDate, empWithoutDate };
    }
    
    @isTest
    static void testAssignInitialLeaveBalancePositive() {
        List<Employee__c> employees = [
            SELECT Id, Name, Joining_Date__c 
            FROM Employee__c 
            WHERE Name IN ('Emp With Date','Emp With Late Date')
        ];
        
        Test.startTest();
        EmployeeTriggerHandler.assignInitialLeaveBalance(employees);
        Test.stopTest();
        
        Map<Id, Leave_Balance__c> leaveBalances = new Map<Id, Leave_Balance__c>(
            [SELECT Id, Employee__c, Leave_Balance__c FROM Leave_Balance__c 
             WHERE Employee__c IN :employees]
        );
        
        for (Employee__c emp : employees) {
            Leave_Balance__c lb = leaveBalances.get(emp.Id);
            System.assertNotEquals(null, lb, 'Leave balance should be created');
            
            if (emp.Joining_Date__c.day() <= 15) {
                System.assertEquals(1, lb.Leave_Balance__c, 'Should assign 1 day if joined before or on 15th');
            } else {
                System.assertEquals(0.5, lb.Leave_Balance__c, 'Should assign 0.5 day if joined after 15th');
            }
        }
    }
    
    @isTest
    static void testAssignInitialLeaveBalanceNegative() {
        Employee__c empWithoutDate = [SELECT Id, Name FROM Employee__c WHERE Name = 'Emp Without Date' LIMIT 1];
        
        Test.startTest();
        EmployeeTriggerHandler.assignInitialLeaveBalance(new List<Employee__c>{ empWithoutDate });
        Test.stopTest();
        
        Integer count = [SELECT count() FROM Leave_Balance__c WHERE Employee__c = :empWithoutDate.Id];
        System.assertEquals(0, count, 'No leave balance should be created if Joining Date is null');
    }
}