/*
 @Name:PractiseMySoqlTest
 @Author:Ankit
 @Description:PractiseTest class
 @Date:29/08/25
*/

@isTest
public class PractiseMySoqlTest {
    @isTest
    static void testUpdatePrimaryContactForAccounts_Positive(){
     Account acc=PractiseTestDataFactory.createAccount('TestAcc1');
     insert acc;
    }

}