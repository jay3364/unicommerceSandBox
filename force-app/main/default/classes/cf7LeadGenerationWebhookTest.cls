@isTest
public class cf7LeadGenerationWebhookTest {
    @IsTest
    public static void TestScenario1() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String jsonBody;
        jsonBody = '{ "your-name": "John Doe", "phoneno": "+911234567890", "your-email": "john.doe@example.com", "CompanyName": "Doe Enterprises", "your-message": "This is a test message.", "your-subject": "Test Subject", "menu-216": "10", "gclid": "testGclid", "utm_campaign": "testCampaign", "utm_source": "testSource", "utm_medium__c": "testMedium", "utm_term": "testTerm", "utm_content": "testContent" }';
        
        req.requestURI = '/services/apexrest/tawkToWebhook/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        cf7LeadGenerationWebhook.cF7LeadGeneration();
        
        jsonBody = '{ "your-name": "John Doe", "phoneno": "1234567890", "your-email": "john.doe@example.com", "CompanyName": "Doe Enterprises", "your-message": "This is a test message.", "your-subject": "Test Subject", "menu-216": "10", "gclid": "testGclid", "utm_campaign": "testCampaign", "utm_source": "testSource", "utm_medium__c": "testMedium", "utm_term": "testTerm", "utm_content": "testContent" }';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        cf7LeadGenerationWebhook.cF7LeadGeneration();

        Test.stopTest();
    }
}