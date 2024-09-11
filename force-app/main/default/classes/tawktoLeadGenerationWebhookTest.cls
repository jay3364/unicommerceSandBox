@IsTest
private class tawktoLeadGenerationWebhookTest {
    @IsTest
    static void testTawktoLeadGeneration() {
        // Set up the mock HTTP request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/tawkToWebhook/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"chatId":"12345","visitor":{"name":"John Doe","email":"john.doe@example.com"},"message":{"text":"Phone : +911234567890\\r\\nCompany : Acme Corp\\r\\nSelect the team you would like to chat : Sales\\r\\n"}}');
        RestContext.request = req;
        
        RestContext.response = res;
        
        Test.startTest();
        tawktoLeadGenerationWebhook.tawktoLeadGeneration();
        Test.stopTest();
    }
}