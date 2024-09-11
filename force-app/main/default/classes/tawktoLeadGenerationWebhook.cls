@RestResource(urlMapping='/tawkToWebhook/*')
global class tawktoLeadGenerationWebhook {


    @HttpPost
    global static responseWrapper tawktoLeadGeneration() {
        String tawktoId;
        String LeadName;
        String LeadPhone;
        String LeadEmail;
        String LeadCompany;
        String LeadTeam;
        String jsonBody;
        Map<String, Object> body = new Map<String, Object>();
        RestRequest req = RestContext.request;
        try {

            jsonBody = req.requestBody.toString();
            body = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);

            System.debug('JSONBody'+ jsonBody);
            System.debug('Body'+ JSON.serialize(body));

            tawktoId = (String)body.get('chatId');
            LeadName = (String)((Map<String, Object>)body.get('visitor')).get('name');
            LeadPhone = ((String)((Map<String, Object>)body.get('message')).get('text')).toString().substringAfter('Phone : ').toString().substringBefore('\r\n');
            LeadEmail = (String)((Map<String, Object>)body.get('visitor')).get('email');
            LeadCompany = ((String)((Map<String, Object>)body.get('message')).get('text')).toString().substringAfter('Company : ').toString().substringBefore('\r\n');
            LeadTeam = ((String)((Map<String, Object>)body.get('message')).get('text')).toString().substringAfter('Select the team you would like to chat : ').toString().substringBefore('\r\n');

            // create lead record
            Lead leadObj = new Lead();
            leadObj.LastName = LeadName;
            leadObj.tawkto_id__c = tawktoId;
            leadObj.Company_Status__c = 'New';
            leadObj.Email = LeadEmail;
            leadObj.Corporate_Email__c = LeadEmail;
            leadObj.api_response__c = jsonBody;

            // validate phone number format
            LeadPhone = LeadPhone.replaceAll(' ', '');
            if(LeadPhone.startsWith('+')) {
                leadObj.Phone = LeadPhone;
                leadObj.Mobile__c = LeadPhone;
            } else if (LeadPhone != null && LeadPhone != '' ){
                leadObj.Phone = '+91' + LeadPhone;
                leadObj.Mobile__c = '+91' + LeadPhone;
            }

            if (LeadCompany == null || LeadCompany == '') {
                leadObj.Company = 'Guest';
            }else {
                leadObj.Company = LeadCompany;
            }

            leadObj.LeadSource = 'Inbound Lead';
            leadObj.Sub_Lead_Source__c = 'Zendesk';
            leadObj.Select_the_team_you_would_like_to_chat__c = LeadTeam;
            insert leadObj;

            responseWrapper response = new responseWrapper();
            response.leadId = leadObj.Id;
            response.name = LeadName;
            response.email = LeadEmail;
            response.phone = LeadPhone;
            response.company = LeadCompany;
            return response;

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            leadGenerationErrorHandler.handleError(e, jsonBody, 'tawktoLeadGenerationWebhook', 'tawktoLeadGeneration', 'Tawk.to', LeadName, LeadEmail, LeadPhone, LeadCompany, LeadTeam, '', '');

            return null;
        }
    }

    global class responseWrapper {  
        public string leadId;
        public string name;
        public string email;
        public String phone;
        public String company;
    }

}