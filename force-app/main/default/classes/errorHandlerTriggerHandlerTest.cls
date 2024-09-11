@isTest
public class errorHandlerTriggerHandlerTest {
    @testSetup
    static void setup() {
        List<Error_Handler__c> errorHandlers = new List<Error_Handler__c>();

        Error_Handler__c error1 = new Error_Handler__c(
            Lead_Name__c = 'Test Lead 1',
            Company__c = 'Test Company 1',
            Email__c = 'test1@test.com',
            Phone__c = '1234567890',
            Lead_Source__c = 'Day Schedule',
            Source_Id__c = 'SourceID1',
            AdditionalDetails__c = 'Details 1',
            Monthly_Orders__c = '10',
            Guest_Emails__c = 'guest1@test.com',
            isEdited__c = false
        );

        Error_Handler__c error2 = new Error_Handler__c(
            Lead_Name__c = 'Test Lead 2',
            Company__c = 'Test Company 2',
            Email__c = 'test2@test.com',
            Phone__c = '0987654321',
            Lead_Source__c = 'Tawk.to',
            Source_Id__c = 'SourceID2',
            AdditionalDetails__c = 'Details 2',
            Monthly_Orders__c = '5',
            Guest_Emails__c = 'guest2@test.com',
            isEdited__c = false
        );

        errorHandlers.add(error1);
        errorHandlers.add(error2);

        insert errorHandlers;
    }

    @isTest
    static void testAfterUpdate() {
        Test.startTest();
        List<Error_Handler__c> errorHandlers = [SELECT Id, Lead_Name__c, Company__c, Email__c, Phone__c, Lead_Source__c, Source_Id__c, AdditionalDetails__c, Monthly_Orders__c, Guest_Emails__c, isEdited__c FROM Error_Handler__c];
        for (Error_Handler__c errorHandler : errorHandlers) {
            errorHandler.Phone__c = '+915432109876';
        }
        errorHandlers[1].Phone__c = '123123123';
        update errorHandlers;
        Test.stopTest();
    }
}