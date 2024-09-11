@RestResource(urlMapping='/contactForm7Webhook/*')
global class cf7LeadGenerationWebhook {
    @HttpPost
    global static responseWrapper cF7LeadGeneration() {
        RestRequest req = RestContext.request;
        Map<String, Object> body = new Map<String, Object>();

        String jsonBody;
        String LeadName;
        String LeadSource;
        String LeadEmail;
        String LeadPhone;
        String LeadCompany;
        String additionalDetails;
        String monthlyOrders;

        try {
            jsonBody = req.requestBody.toString();
            body = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);

            System.debug('JSONBody' + jsonBody);
            System.debug('Body' + JSON.serialize(body));

            Lead newLead = new Lead();
            LeadSource = 'Contact Form 7';
            newLead.LastName = (String) body.get('your-name');
            LeadName = (String) body.get('your-name');
            newLead.LeadSource = 'Inbound Lead';
            newLead.Sub_Lead_Source__c = 'Mail';
            newLead.Company_Status__c = 'New';
            newLead.API_Response__c = jsonBody;

            if ((String) body.get('phoneno') != null) {
                newLead.Phone = (String) body.get('phoneno');
                newLead.Mobile__c = (String) body.get('phoneno');
                LeadPhone = (String) body.get('phoneno');
            }
            if ((String) body.get('your-email') != null) {
                newLead.Email = (String) body.get('your-email');
                newLead.Corporate_Email__c = (String) body.get('your-email');
                LeadEmail = (String) body.get('your-email');
            }

            if ((String) body.get('CompanyName') != null) {
                newLead.Company = (String) body.get('CompanyName');
                LeadCompany = (String) body.get('CompanyName');
            } else {
                newLead.Company = 'Guest';
                LeadCompany = 'Guest';
            }
            if ((String) body.get('your-message') != null) {
                newLead.Description = (String) body.get('your-message');
                additionalDetails = (String) body.get('your-message');
            }
            if ((String) body.get('your-subject') != null) {
                newLead.Web_Notes__c = (String) body.get('your-subject');
            }
            if ((String) body.get('menu-216') != null) {
                newLead.No_of_Monthly_Order__c = (String) body.get('menu-216');
                monthlyOrders = (String) body.get('menu-216');
            }
            if ((String) body.get('gclid') != null && (String) body.get('gclid') != ''){
                newLead.gclid__c = (String) body.get('gclid');
            }else if ((String) body.get('gclid_field') != null && (String) body.get('gclid_field') != ''){
                newLead.gclid__c = (String) body.get('gclid_field');
            }
            if ((String) body.get('utm_campaign') != null) {
                newLead.utm_campaign__c = (String) body.get('utm_campaign');
            }
            if ((String) body.get('utm_source') != null) {
                newLead.utm_source__c = (String) body.get('utm_source');
            }
            if ((String) body.get('utm_medium__c') != null) {
                newLead.utm_medium__c = (String) body.get('utm_medium');
            }
            if ((String) body.get('utm_term') != null) {
                newLead.utm_term__c = (String) body.get('utm_term');
            }
            if ((String) body.get('utm_content') != null) {
                newLead.utm_content__c = (String) body.get('utm_content');
            }
            insert newLead;

            responseWrapper response = new responseWrapper();

            response.name = LeadName;
            response.Id = newLead.Id;

            return response;
        } catch (Exception e) {
            leadGenerationErrorHandler.handleError(
                e,
                jsonBody,
                'cf7LeadGenerationWebhook',
                'cF7LeadGeneration',
                LeadSource,
                LeadName,
                LeadEmail,
                LeadPhone,
                LeadCompany,
                additionalDetails,
                monthlyOrders,
                ''
            );
            return null;
        }
    }
    global class responseWrapper {
        public string name;
        public string Id;
    }
}