public with sharing class errorHandlerTriggerHandler {
    public static void afterUpdate(
        List<Error_Handler__c> newRecordsList,
        Map<Id, Error_Handler__c> oldMap,
        Map<Id, Error_Handler__c> newMap,
        List<Error_Handler__c> oldRecordsList
    ) {
        if (triggerRecursionHelper.isTriggerExecuted) {
            return;
        }

        triggerRecursionHelper.isTriggerExecuted = true;

        try {
            List<lead> leadsToCreate = new List<lead>();
            List<Error_Handler__c> recordsToUpdate = new List<Error_Handler__c>();
            for (Error_Handler__c newRecord : newRecordsList) {
                System.debug('Inside For');
                if (!newRecord.isEdited__c) {
                    System.debug('Inside If');
                    lead newLead = new lead();
                    String cleanedPhone = '';
                    if (newRecord.Error_Message__c != null && newRecord.Error_Message__c.contains('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Please use the accurate format is [+][country code][area code][local phone number]')) {
                        if (newRecord.Phone__c != null) {
                           
                            for (Integer i = 0; i < newRecord.Phone__c.length(); i++) {
                                String currentChar = newRecord.Phone__c.substring(i, i+1);
                                if(i == 0 && currentChar != '+'){
                                    cleanedPhone = '+' + currentChar; 
                                } else if( i != 0 && currentChar != '+' && (currentChar >= '0' && currentChar <= '9') ){
                                    cleanedPhone += currentChar;
                                }
                            }
                        }
                        
                        
                        
                        System.debug('Custom validation exception found in Error_Message__c');
                    }
                    newLead.LastName = newRecord.Lead_Name__c;
                    newLead.Company = newRecord.Company__c;
                    newLead.Email = newRecord.Email__c;
                    newLead.Corporate_Email__c = newRecord.Email__c;
                    newLead.Phone = cleanedPhone;
                    newLead.Mobile__c = cleanedPhone;
                    newLead.LeadSource = 'Inbound Lead';

                    if (newRecord.Lead_Source__c == 'Day Schedule') {
                        newLead.DaySchedule_ID__c = newRecord.Source_Id__c;
                        newLead.Web_Notes__c = newRecord.AdditionalDetails__c;
                        newLead.Sub_Lead_Source__c = 'Calendly';
                        
                    } else if (newRecord.Lead_Source__c == 'Tawk.to') {
                        newLead.tawkto_id__c = newRecord.Source_Id__c;
                        newLead.Select_the_team_you_would_like_to_chat__c = newRecord.AdditionalDetails__c;
                        newLead.Sub_Lead_Source__c = 'Zendesk';
                    } else {
                        newLead.Sub_Lead_Source__c = 'Mail';
                    }
                    newLead.No_of_Monthly_Order__c = newRecord.Monthly_Orders__c;
                    newLead.Guest_Emails__c = newRecord.Guest_Emails__c;
                    newLead.Error_Record__c = newRecord.Id;
                    newLead.gclid__c = newRecord.gclid__c;
                    newLead.utm_campaign__c = newRecord.utm_campaign__c;
                    newLead.utm_source__c = newRecord.utm_source__c;
                    newLead.utm_medium__c = newRecord.utm_medium__c;
                    newLead.utm_term__c = newRecord.utm_term__c;
                    newLead.utm_content__c = newRecord.utm_content__c;
                    newLead.Meeting_Link__c = newRecord.Meeting_Link__c;
                    newLead.Scheduled_Start_Time__c = newRecord.Scheduled_Start_Time__c;
                    newLead.Scheduled_End_Time__c = newRecord.Scheduled_End_Time__c;
                    newLead.Company_Status__c = 'New';
                    leadsToCreate.add(newLead);
                }
            }
            if (!leadsToCreate.isEmpty()) {
                try {
                    Database.SaveResult[] results = Database.insert(
                        leadsToCreate,
                        false
                    );
                    for (Integer i = 0; i < results.size(); i++) {
                        if (results[i].isSuccess()) {
                            Error_Handler__c recordToUpdate = new Error_Handler__c();
                            recordToUpdate.Id = leadsToCreate[i]
                                .Error_Record__c;
                            recordToUpdate.Error_Message__c = 'Resolved';
                            recordToUpdate.Error_Description__c = 'Resolved';
                            recordToUpdate.isEdited__c = true;
                            recordsToUpdate.add(recordToUpdate);

                            if (leadsToCreate[i].LeadSource == 'Inbound Lead' && leadsToCreate[i].Sub_Lead_Source__c == 'Calendly') {

                                List<Event> newEventList = new List<Event>();
                                // start time and end time not null
                                if (leadsToCreate[i].Scheduled_Start_Time__c != null && leadsToCreate[i].Scheduled_End_Time__c != null) {
                                    Event newEvent = new Event();
                                    newEvent.Subject = 'Online Demo';
                                    newEvent.StartDateTime = leadsToCreate[i].Scheduled_Start_Time__c;
                                    newEvent.EndDateTime = leadsToCreate[i].Scheduled_End_Time__c;
                                    newEvent.Description = 'Meeting with ' + leadsToCreate[i].LastName + ' via Calendly';
                                    newEvent.WhoId = leadsToCreate[i].Id;
                                    newEventList.add(newEvent);
                                }  
                                insert newEventList;
                            }

                        } else {
                            Error_Handler__c recordToUpdate = new Error_Handler__c();
                            recordToUpdate.Id = leadsToCreate[i]
                                .Error_Record__c;
                            recordToUpdate.Error_Description__c = results[i]
                                    .getErrors()[0]
                                .getMessage();
                            recordToUpdate.Error_Message__c = results[i]
                                    .getErrors()[0]
                                .getMessage();
                            recordsToUpdate.add(recordToUpdate);
                        }
                    }
                } catch (Exception e) {
                    System.debug(
                        'Error during Lead insertion: ' + e.getMessage()
                    );
                }
            }

            if (!recordsToUpdate.isEmpty()) {
                try {
                    update recordsToUpdate;
                } catch (Exception e) {
                    System.debug(
                        'Error updating Error_Handler__c records: ' +
                        e.getMessage()
                    );
                }
            }
        } catch (Exception e) {
            System.debug('Error in afterUpdate: ' + e.getMessage());
        }
    }
}