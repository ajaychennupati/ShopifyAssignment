public class viewJobPostings{
    @AuraEnabled
    public static List<account> getDepartmentsList(){
        try{
           //Querying the list of Departments whic are sponsering
            List<Account> DepartmentsList = new List<Account>();
            for(Account each:[select id,Name from account where id In (select Internal_Department__c from Sponsor__c)]){
                DepartmentsList.add(each);
            }
            if(!DepartmentsList.isEmpty()){
                return DepartmentsList;
            }else{ 
                AuraHandledException ae =  new AuraHandledException('There is No data, Please reachout Admin' );
                ae.setMessage('There is No data, Please reachout Admin'); 
                throw ae;  
              }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }   
    }
    
   @AuraEnabled
   public static List<JobswrapperClass> getJobsByDepartment(String DepartmentId){
       try{
           List<JobswrapperClass> response = new List<JobswrapperClass>();
          //Querying the list of Sponsor__c which are related to the department user selected in the UI
           for(Sponsor__c each:[select Id,Internal_Department__c,Internal_Department__r.name,Job__c,Job__r.Status__c,Job__r.name,Job__r.Salary_Information__c from Sponsor__c where Internal_Department__c =:DepartmentId]){
               JobswrapperClass wrapper = new JobswrapperClass();
               wrapper.JobTitile = each.Job__r.name ;
               wrapper.JobId = each.Job__r.name ;
               wrapper.SalaryInformation = each.Job__r.Salary_Information__c;
               wrapper.DepartmentName = each.Internal_Department__r.name;
               wrapper.DepartmentId = each.Internal_Department__c;
               wrapper.Status = each.Job__r.Status__c;
               response.add(wrapper);
           }
      
           if(!response.isEmpty()){
                return response;
           }else{ 
                        AuraHandledException ae =  new AuraHandledException('There is No data, Please reachout Admin' );
                        ae.setMessage('There is No data, Please reachout Admin'); 
                        throw ae;  
           }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }   
   }
   @AuraEnabled
   public static List<JobApplicationswrapperClass> getJobApplicationInfo(String jobId){
       
       try{
           List<JobApplicationswrapperClass> response = new List<JobApplicationswrapperClass>();
           //Querying the list of Job_Application__c which are related to the Job position whichuser selected in the UI
           for(Job_Application__c each:[select id,name,Job__c,Job__r.name,Applicant__c,Applicant__r.name,Applicant__r.Email,Status__c from Job_Application__c where Job__r.Name=:jobid]){
               JobApplicationswrapperClass wrapper = new JobApplicationswrapperClass();
               wrapper.JobTitile = each.Job__r.name ;
               wrapper.JobApplicationId = each.Id;
               wrapper.CandidateName = each.Applicant__r.name;
               wrapper.Email = each.Applicant__r.Email;
               wrapper.Status = each.Status__c;
               response.add(wrapper);
           }
           if(!response.isEmpty()){
                return response;
            }else{ 
                AuraHandledException ae =  new AuraHandledException('There is No data, Please reachout Admin' );
                ae.setMessage('There is No data, Please reachout Admin'); 
                throw ae;  
             }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }  
   }
   public class JobswrapperClass{
        @AuraEnabled public String JobTitile{get;set;}
        @AuraEnabled public String JobId{get;set;}
        @AuraEnabled public String SalaryInformation{get;set;}
        @AuraEnabled public String DepartmentName {get;set;}
        @AuraEnabled public String DepartmentId {get;set;}  
        @AuraEnabled public String Status{get;set;}        
    }
    public class JobApplicationswrapperClass{
        @AuraEnabled public String JobTitile{get;set;}
        @AuraEnabled public Id JobApplicationId{get;set;}
        @AuraEnabled public String CandidateName{get;set;}
        @AuraEnabled public String Email{get;set;} 
        @AuraEnabled public String Status{get;set;}  
             
    }
}