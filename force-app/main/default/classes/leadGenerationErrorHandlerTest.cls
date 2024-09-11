@isTest
public class leadGenerationErrorHandlerTest {
  @isTest
  static void testHandleError() {
    Test.startTest();

    // Exception exp = new DmlException();

    try {
      Lead l = new Lead();
      l.LastName = 'Test';
      l.LeadSource = 'Day Schedule';
      l.phone = '+91+911231231231';
      insert l;
    } catch (Exception e) {
      System.debug(e.getDmlFields(0));
      leadGenerationErrorHandler.handleError(
        e,
        '{"chatId":"12345","visitor":{"name":"John Doe","email":"john.doe@example.com"},"message":{"text":"Phone : +911234567890\\r\\nCompany : Acme Corp\\r\\nSelect the team you would like to chat : Sales\\r\\n"}}',
        'TestClassName',
        'TestMethodName',
        'Day Schedule',
        'Test Lead',
        'testlead@example.com',
        '1234567890',
        'Test Company',
        'Test Additional Details',
        '10',
        'guest@example.com'
        );
        
    }
    Test.stopTest();
  }
}