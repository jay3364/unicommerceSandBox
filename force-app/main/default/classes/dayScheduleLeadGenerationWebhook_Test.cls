@isTest
private class dayScheduleLeadGenerationWebhook_Test {

    @isTest
    static void testValidLeadCreation() {
        // Test valid lead creation scenario
        RestRequest request = createMockRestRequest('John Doe', 'john@example.com', '+911234567890', 'ABC Company', 'Additional details', '5', 'guest1@example.com');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        dayScheduleLeadGenerationWebhook.responseWrapper result = dayScheduleLeadGenerationWebhook.dayScheduleLeadGeneration();
    }

    @isTest
    static void testInvalidEmailFormat() {
        // Test scenario where email format is invalid
        RestRequest request = createMockRestRequest('Jane Doe', 'invalidemail', '1234567890', '', 'Details', '10', 'guest2@example.com');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        dayScheduleLeadGenerationWebhook.responseWrapper result = dayScheduleLeadGenerationWebhook.dayScheduleLeadGeneration();
    }

    // Helper method to create a mock REST request
    static RestRequest createMockRestRequest(String name, String email, String phone, String company, String additionalDetails, String monthlyOrders, String guestEmails) {
        RestRequest request = new RestRequest();
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, Object> booking = new Map<String, Object>{'key' => 'value'};
        Map<String, Object> invitee = new Map<String, Object>{'key' => 'value'};
        List<Object> questions = new List<Object>();

        Map<String, Object> question1 = new Map<String, Object>{'label' => 'Name', 'name' => 'name', 'type' => 'string', 'value' => name};
        Map<String, Object> question2 = new Map<String, Object>{'label' => 'Email', 'name' => 'email', 'type' => 'string', 'value' => email};
        Map<String, Object> question3 = new Map<String, Object>{'label' => 'Mobile', 'name' => 'mobile', 'type' => 'string', 'value' => phone};
        Map<String, Object> question4 = new Map<String, Object>{'label' => 'Company', 'name' => 'name_3', 'type' => 'string', 'value' => company};
        Map<String, Object> question5 = new Map<String, Object>{'label' => 'Additional Details', 'name' => 'please_share', 'type' => 'string', 'value' => additionalDetails};
        Map<String, Object> question6 = new Map<String, Object>{'label' => 'Monthly Orders', 'name' => 'no_of', 'type' => 'string', 'value' => monthlyOrders};
        Map<String, Object> question7 = new Map<String, Object>{'label' => 'Guest Emails', 'name' => 'guest_emails', 'type' => 'string', 'value' => guestEmails};

        questions.add(question1);
        questions.add(question2);
        questions.add(question3);
        questions.add(question4);
        questions.add(question5);
        questions.add(question6);
        questions.add(question7);

        invitee.put('questions', questions);
        Map<String,Object> location = new Map<String, Object>();
		booking.put('start_at','2024-06-28T13:10:00.000Z');
        booking.put('_id','01234567890');
        booking.put('end_at','2024-06-28T13:15:00.000Z');
        location.put('join_url','https://google.com');
        booking.put('location', location);

        Map<String, Object> utm = new Map<String, Object>();
        utm.put('utm_source', 'google');
        utm.put('utm_medium', '1231wetsefefsefddf');
        utm.put('utm_term', '12sfefdsndjlrng');
        utm.put('utm_campaign', 'google ads');
        utm.put('utm_content', 'google ads content');
        utm.put('gclid', '1234567890');
        invitee.put('utm', utm);
        requestBody.put('booking', booking);
        requestBody.put('invitee', invitee);
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        return request;
    }
}