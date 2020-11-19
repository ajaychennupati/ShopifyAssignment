/********************** Description Section **********************
@Name           : jobApplicationHandlerAPI
@Author         : Ajay Chennupati
@CreateDate     : 11/18/2020
@Description    : This API will Store the JobApplications and Applicants
@APIEndPoint    : https://test-1c0-dev-ed.my.salesforce.com/services/apexrest/JobApplications
@SampleJSON     :
[
  {
    "FirstName": "Test1",
    "LastName": "User",
    "Email": "test1@gmail.com",
    "PhoneNumber": "1234567890",
    "JobId": "a014x000001giQ8"
  },
  {
    "FirstName": "Test2",
    "LastName": "User",
    "Email": "test2@gmail.com",
    "PhoneNumber": "1234567890",
    "JobId": "a014x000001giUL"
  }
]
****************************************************************/

@RestResource(urlMapping = '/JobApplications/*')
global with Sharing class JobApplicationHandlerAPI {
   
    @HttpPost
    global static void getJobApplicationApiRequest(){
         //logging for analyzing API response times
         Long apiCallStartTime = system.currentTimeMillis();
         RestRequest req = RestContext.request;
         String jsonBody = req.requestBody.toString();
         // reading the request body and converting in to a String
         System.debug(jsonBody);
         //Deserializing body into a list
         List<Object> request = new List<Object>((List<Object>)JSON.deserializeUntyped(jsonBody));
         //List to insert the job applications in bulk
         List<Job_Application__c> JobApplicationsToInsert = new List<Job_Application__c>();
         Map<String,SObject> ApplicantsToInsert = new Map<String,SObject>();
         SavePoint Sp = Database.setSavePoint();
         try{
             Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Contact');
             if(request!=null && !request.isEmpty()){
                 for(Object each: request){
                     Map<String, object> ApplicantInfo = (Map<String, object>)Each;
                     SObject ApplicantRecord = targetType.newSObject();  
                     ApplicantRecord.put('FirstName',ApplicantInfo.get('FirstName'));
                     ApplicantRecord.put('LastName',ApplicantInfo.get('LastName'));
                     ApplicantRecord.put('Email',ApplicantInfo.get('Email'));
                     ApplicantRecord.put('Phone',ApplicantInfo.get('PhoneNumber'));
                     ApplicantsToInsert.put(String.valueOf(ApplicantInfo.get('JobId')),ApplicantRecord);
                 }
             }
            // database query to get list of success & failures 
            Database.SaveResult[] InsertedApplicants = Database.Insert(ApplicantsToInsert.values(), false);
            for(Database.SaveResult sr : InsertedApplicants){
                if(!sr.isSuccess()){
                    String error_msg = '';
                    for(Database.Error err: sr.getErrors()) {
                        error_msg += err.getStatusCode() + ': ' + err.getMessage()+' fields that affected this error: '+err.getFields();
                    }
                   System.debug('Exception from getJobApplicationApiRequest : ' + error_msg); 
                }
            }
           for(String each: ApplicantsToInsert.keySet()){
               if(ApplicantsToInsert.ContainsKey(each) && ApplicantsToInsert.get(each).Id != null)
                   JobApplicationsToInsert.add(new Job_Application__c(Job__c=each,Applicant__c=ApplicantsToInsert.get(each).Id));
           }
            if(!JobApplicationsToInsert.isEmpty()){
                Database.SaveResult[] InsertedJobApplications = Database.Insert(JobApplicationsToInsert, false);
                for(Database.SaveResult sr : InsertedJobApplications){
                if(!sr.isSuccess()){
                    String error_msg = '';
                    for(Database.Error err: sr.getErrors()) {
                        error_msg += err.getStatusCode() + ': ' + err.getMessage()+' fields that affected this error: '+err.getFields();
                    }
                   System.debug('Exception from getJobApplicationApiRequest : ' + error_msg); 
                }
            }
            }
            generateJsonContent('SUCCESS','200','', System.currentTimeMillis()-apiCallStartTime);
         }catch(Exception ex){
            //rollback the transaction incase of failures
            Database.rollback(Sp);
            String errMsg = 'getJobApplicationApiRequestFailure-' + ex.getMessage()+' at Line No - '+ex.getLineNumber();
            system.debug(errMsg);
            //String addresses = Services__c.getValues('EmailNotificationQueue').Emails__c;
            String addresses = 'ajay.test@gmail.com';
            List<String> toAddresses = addresses.split(',');
            String errorLog = 'Content of Attachment';
            // Email notification with error logs
            sendEmail(toAddresses, 'getJobApplicationApiRequest Failured',errMsg, errorLog);
            generateJsonContent('FAILURE','400',errMsg, System.currentTimeMillis()-apiCallStartTime);
         }   
    }
    global static void  generateJsonContent(String status, String StatusCode, String exceptionMsg, Long Interval){
        String jsonResponse; 
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('Status', status);
        gen.writeStringField('StatusCode', StatusCode);   
        gen.writeStringField('Interval', String.valueOf(Interval)+'MSec');  
        if(!String.isEmpty(exceptionMsg))
            gen.writeStringField('ErrorMsg',exceptionMsg);  
        gen.writeEndObject();
        system.debug('gen---'+gen);
        jsonResponse = gen.getAsString();
        RestContext.response.addHeader('Content-Type','application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonResponse);        
    }
    /**
  * @author PSI
  * @date 09/11/2015
  * @description This method is used to send email notification with dynamic attachment name (Order)
  * @param List<String> toAddresses
  * @param String subject
  * @param String emailBody
  * @return
  */
  global static void sendEmail(List<String> toAddresses, String subject , String emailBody, String attachmentName) {

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setSubject( subject );
    email.setToAddresses( toAddresses );
    email.setPlainTextBody( emailBody );
    email.setCcAddresses(toAddresses);
    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    efa.setFileName(attachmentName);
    efa.setContentType('application/pdf');
    Blob attachment;
    efa.setBody(attachment);
    efa.setInline(false);
    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
    // Sends the email
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

  }
}