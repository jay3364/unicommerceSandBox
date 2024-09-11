public with sharing class leadGenerationErrorHandler {

    public static void handleError(Exception e, String jsonBody, String ClassName, String MethodName, String LeadSource,String LeadName,String LeadEmail,String LeadPhone,String LeadCompany,string additionalDetails,string monthlyOrders,string guestEmails) {
        try {
            Error_Handler__c errorObj = new Error_Handler__c();
            
            Map<String,Object> body = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
            Map<String, Object> errorDetails = new Map<String, Object>();
            errorDetails.put('ExceptionType', 'DmlException');
            errorDetails.put('Message', e.getMessage());
            errorDetails.put('Line Number', e.getLineNumber());
            // errorDetails.put('Fields', e.getDmlFields(0));
 
            String serializedError = JSON.serialize(errorDetails);
            
            errorObj.Class_Name__c = ClassName;
            errorObj.Method_Name__c = MethodName;
            errorObj.Error_Description__c = serializedError;
            errorObj.Error_Message__c = e.getMessage();
            errorObj.Line_Number__c = e.getLineNumber();
            errorObj.Api_Response__c = jsonBody;
            errorObj.Lead_Source__c = LeadSource;
            errorObj.Lead_Name__c = LeadName;
            errorObj.Email__c = LeadEmail;
            errorObj.Phone__c = LeadPhone;
            errorObj.Company__c = LeadCompany;
            errorObj.AdditionalDetails__c = additionalDetails;
            errorObj.Monthly_Orders__c = monthlyOrders;
            errorObj.Guest_Emails__c = guestEmails;

            System.debug(errorObj);
            if (errorObj.Lead_Source__c == 'Day Schedule') {
                Map<String, Object> booking = (Map<String, Object>)body.get('booking');
                Map<String, Object> invitee = (Map<String, Object>)body.get('invitee');
                Map<String, Object> location = new Map<String, Object>();
                if (booking.get('location') != null) {
                    location = (Map<String, Object>)booking.get('location');
                }
                Map<String, Object> utm = new Map<String, Object>();
                errorObj.Source_Id__c = (String)booking.get('_id');
                if (invitee.get('utm') != null){
                    utm = (Map<String, Object>)invitee.get('utm');
                }
                if(utm != null) {
                    if ((String)utm.get('utm_source') != null && ((String)utm.get('utm_source')) != '') {
                        errorObj.UTM_Source__c = (String)utm.get('utm_source');
                    }
                    if ((String)utm.get('utm_medium') != null && ((String)utm.get('utm_medium')) != '') {
                        errorObj.UTM_Medium__c = (String)utm.get('utm_medium');
                    }
                    if ((String)utm.get('utm_term') != null && ((String)utm.get('utm_term')) != '') {
                        errorObj.UTM_Term__c = (String)utm.get('utm_term');
                    }
                    if ((String)utm.get('utm_campaign') != null && ((String)utm.get('utm_campaign')) != '') {
                        errorObj.UTM_Campaign__c = (String)utm.get('utm_campaign');
                    }
                    if ((String)utm.get('utm_content') != null && ((String)utm.get('utm_content')) != '') {
                        errorObj.UTM_Content__c = (String)utm.get('utm_content');
                    }
                    if ((String)utm.get('gclid') != null && ((String)utm.get('gclid')) != '') {
                        errorObj.GCLID__c = (String)utm.get('gclid');
                    }
                }
                if (location != null) {
                    errorObj.Meeting_Link__c = (String)location.get('join_url');
                    errorObj.Scheduled_Start_Time__c = convertToDateTime((String)booking.get('start_at'));
                    errorObj.Scheduled_End_Time__c = convertToDateTime((String)booking.get('end_at'));
                }
                
            } else if (errorObj.Lead_Source__c == 'Tawk.to') {
                errorObj.Source_Id__c = (String)body.get('chatId');
            } else if (errorObj.Lead_Source__c == 'Contact Form 7') {
                if ((String)body.get('gclid') != null) {
                    errorObj.gclid__c = (String)body.get('gclid');
                }
                if ((String)body.get('utm_campaign') != null) {
                    errorObj.utm_campaign__c = (String)body.get('utm_campaign');
                }
                if ((String)body.get('utm_source') != null) {
                    errorObj.utm_source__c = (String)body.get('utm_source');
                }
                if ((String)body.get('utm_medium__c') != null) {
                    errorObj.utm_medium__c = (String)body.get('utm_medium');
                }
                if ((String)body.get('utm_term') != null) {
                    errorObj.utm_term__c = (String)body.get('utm_term');
                }
                if ((String)body.get('utm_content') != null) {
                    errorObj.utm_content__c = (String)body.get('utm_content');
                }                   
            }

           
            
            insert errorObj;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { 'mitraj.g@mvclouds.com' };
            mail.setToAddresses(toAddresses);
            mail.setSubject('Error in Lead Generation Webhook');
            mail.setPlainTextBody('Error: ' + e.getMessage() + '\nLine Number:' + e.getLineNumber() + '.\nRequest Body: ' + jsonBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        } catch (Exception error) {
            System.debug('Error in leadGenerationErrorHandler: ' + error.getMessage());
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { 'vidit.s@mvclouds.com' };
            mail.setToAddresses(toAddresses);
            mail.setSubject('Error in Lead Generation Error Handler');
            mail.setPlainTextBody('Error: ' + error.getMessage() + '\nLine Number:' + error.getLineNumber() + '. \n\nRequest Body: ' + jsonBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public static Datetime convertToDateTime (String dateString){
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
            Integer.valueOf(timeParts[2])  // Second
        );
        return datetimeObject;
    }
}