/********************** Description Section **********************
@Name           : JobsTriggerhelper
@Author         : Ajay Chennupati
@CreateDate     : 11/18/2020
@Description    : This Component helps to inactivate the Job_Application__c when parent Job__c is Inactivated
****************************************************************/

public class JobsTriggerhelper {
    public static void onAfterUpdate(Map<Id,Job__c> newMap, Map<Id,Job__c> oldMap){
        // Set to hold all inactive jobIDs
        Set<id> inActiveJobIds = new Set<id>();
        // List of all job applications for updating statuses to inactive
        List<Job_Application__c> JobApplicationNeedtoUpdate = new List<Job_Application__c> ();
        for(Job__c eachJob: newMap.values()){
            if(eachJob.Status__c =='InActive' && eachJob.Status__c != oldMap.get(eachJob.Id).Status__c){
                inActiveJobIds.add(eachJob.id);
            }
        }
        if(!inActiveJobIds.isEmpty()){
             //Query to get list job applications for only inactive jobs
             for(Job_Application__c each:[Select id,Status__c from Job_Application__c where Job__c In: inActiveJobIds and Status__c !='InActive']){
                 each.Status__c = 'InActive';
                 JobApplicationNeedtoUpdate.add(each);
             } 
             if(!JobApplicationNeedtoUpdate.isEmpty()){
                 Update JobApplicationNeedtoUpdate;
             }
        }
    }
}