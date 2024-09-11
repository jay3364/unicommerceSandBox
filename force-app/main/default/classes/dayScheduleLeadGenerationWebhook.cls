@RestResource(urlMapping='/DayScheduleWebhook/*')
global class dayScheduleLeadGenerationWebhook {
    @HttpPost
    global static responseWrapper dayScheduleLeadGeneration() {
        RestRequest req = RestContext.request;
        String LeadName;
        String LeadEmail;
        String LeadPhone;
        String LeadCompany;
        string additionalDetails;
        string monthlyOrders;
        string guestEmails;
        Lead leadObj = new Lead();
        Map<String, Object> body = new Map<String, Object>();
        String jsonBody;
        responseWrapper response = new responseWrapper();
        try {
            jsonBody = req.requestBody.toString();
            body = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);

            System.debug('JSONBody' + jsonBody);
            System.debug('Body' + JSON.serialize(body));

            Map<String, Object> booking = (Map<String, Object>) body.get(
                'booking'
            );
            Map<String, Object> invitee = (Map<String, Object>) body.get(
                'invitee'
            );
            Map<String, Object> location = new Map<String, Object>();
            List<Object> questions = (List<Object>) invitee.get('questions');

            Map<String, Object> utm = new Map<String, Object>();
            if (invitee.get('utm') != null) {
                utm = (Map<String, Object>) invitee.get('utm');
            }

            if (booking.get('location') != null) {
                location = (Map<String, Object>) booking.get('location');
            }

            for (Object questionObj : questions) {
                Map<String, Object> question = (Map<String, Object>) questionObj;
                String label = (String) question.get('label');
                String name = (String) question.get('name');
                String type = (String) question.get('type');
                String value = (String) question.get('value'); // assuming all values are strings for simplicity

                if (name == 'name') {
                    LeadName = value;
                } else if (name == 'email') {
                    LeadEmail = value;
                } else if (name == 'mobile') {
                    LeadPhone = value;
                } else if (name == 'name_3') {
                    LeadCompany = value;
                } else if (name == 'no_of') {
                    monthlyOrders = value;
                } else if (name == 'please_share') {
                    additionalDetails = value;
                } else if (label == 'Guest Emails') {
                    guestEmails = value;
                }
            }
            leadObj.API_Response__c = jsonBody;
            leadObj.LastName = LeadName;
            leadObj.Company_Status__c = 'New';
            leadObj.Meeting_Link__c = (String) location.get('join_url');
            leadObj.Scheduled_Start_Time__c = convertToDateTime(
                (String) booking.get('start_at')
            );
            leadObj.Scheduled_End_Time__c = convertToDateTime(
                (String) booking.get('end_at')
            );
            leadObj.LeadSource = 'Inbound Lead';
            leadObj.Sub_Lead_Source__c = 'Calendly';
            if (
                (String) booking.get('_id') != null &&
                ((String) booking.get('_id')) != ''
            ) {
                leadObj.DaySchedule_ID__c = (String) booking.get('_id');
            }
            if (LeadEmail != null && LeadEmail.length() > 0) {
                leadObj.Email = LeadEmail;
                leadObj.Corporate_Email__c = LeadEmail;
            }
            if (LeadPhone != null && LeadPhone.length() > 0) {
                LeadPhone = LeadPhone.replaceAll(' ', '');
                leadObj.Phone = LeadPhone;
                leadObj.Mobile__c = LeadPhone;
            }
            if (LeadCompany != null && LeadCompany.length() > 0) {
                leadObj.Company = LeadCompany;
            } else {
                leadObj.Company = 'Guest';
            }
            if (monthlyOrders != null && monthlyOrders.length() > 0) {
                leadObj.No_of_Monthly_Order__c = monthlyOrders;
            }
            if (additionalDetails != null && additionalDetails.length() > 0) {
                leadObj.Web_Notes__c = additionalDetails;
            }
            if (guestEmails != null && guestEmails.length() > 0) {
                leadObj.Guest_Emails__c = guestEmails;
            }
            if (utm != null) {
                if (
                    (String) utm.get('utm_source') != null &&
                    ((String) utm.get('utm_source')) != ''
                ) {
                    leadObj.UTM_Source__c = (String) utm.get('utm_source');
                }
                if (
                    (String) utm.get('utm_medium') != null &&
                    ((String) utm.get('utm_medium')) != ''
                ) {
                    leadObj.UTM_Medium__c = (String) utm.get('utm_medium');
                }
                if (
                    (String) utm.get('utm_term') != null &&
                    ((String) utm.get('utm_term')) != ''
                ) {
                    leadObj.UTM_Term__c = (String) utm.get('utm_term');
                }
                if (
                    (String) utm.get('utm_campaign') != null &&
                    ((String) utm.get('utm_campaign')) != ''
                ) {
                    leadObj.UTM_Campaign__c = (String) utm.get('utm_campaign');
                }
                if (
                    (String) utm.get('utm_content') != null &&
                    ((String) utm.get('utm_content')) != ''
                ) {
                    leadObj.UTM_Content__c = (String) utm.get('utm_content');
                }
                if (
                    (String) utm.get('gclid') != null &&
                    ((String) utm.get('gclid')) != ''
                ) {
                    leadObj.GCLID__c = (String) utm.get('gclid');
                }
            }

            response.leadId = leadObj.Id;
            response.name = LeadName;
            response.email = LeadEmail;
            response.phone = LeadPhone;
            response.company = LeadCompany;
            response.additionalDetails = additionalDetails;
            response.monthlyOrders = monthlyOrders;
            response.guestEmails = guestEmails;

            insert leadObj;

            Event e = new Event();
            e.Subject = 'Online Demo';
            e.WhoId = leadObj.Id;
            e.StartDateTime = leadObj.Scheduled_Start_Time__c;
            e.EndDateTime = leadObj.Scheduled_End_Time__c;
            e.Description = 'Meeting with ' + leadObj.LastName + ' via Calendly.';
            if (leadObj.Meeting_Link__c != null && leadObj.Meeting_Link__c != '') {
                e.Description += '\n' + 'Meeting link ' + leadObj.Meeting_Link__c;
            }
            if (leadObj.Web_Notes__c != null && leadObj.Web_Notes__c != '') {
                e.Description += '\n' + 'Discussion Topics ' + leadObj.Web_Notes__c;
            }
            insert e;

            return response;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            leadGenerationErrorHandler.handleError(
                e,
                jsonBody,
                'dayScheduleLeadGenerationWebhook',
                'dayScheduleLeadGeneration',
                'Day Schedule',
                LeadName,
                LeadEmail,
                LeadPhone,
                LeadCompany,
                additionalDetails,
                monthlyOrders,
                guestEmails
            );
            return null;
        }
    }

    global class responseWrapper {
        public string leadId;
        public string name;
        public string email;
        public String phone;
        public String company;
        public String additionalDetails;
        public string monthlyOrders;
        public string guestEmails;
    }

    public static Datetime convertToDateTime(String dateString) {
        dateString = dateString.replace('Z', '');
        String datePart = dateString.substringBefore('T');
        String timePart = dateString.substringAfter('T');
        String[] dateParts = datePart.split('-');
        String[] timeParts = timePart.split(':|\\.');
        DateTime datetimeObject = DateTime.newInstance(
            Integer.valueOf(dateParts[0]), // Year
            Integer.valueOf(dateParts[1]), // Month
            Integer.valueOf(dateParts[2]), // Day
            Integer.valueOf(timeParts[0]), // Hour
            Integer.valueOf(timeParts[1]), // Minute
            Integer.valueOf(timeParts[2]) // Second
        );
        return datetimeObject;
    }
}