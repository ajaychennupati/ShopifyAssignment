({
	   doInit : function(component,event,helper){
        var action = component.get('c.getDepartmentsList');        
        action.setParams({});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set('v.DepartmentsList',response.getReturnValue());
            }else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.resultMessage","Error message: "+errors[0].message);
                    }
                } else {
                    component.set("v.resultMessage","Unknown error");
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
       },
    onChangeDepartmentsList: function(component, event, helper) {
       console.log('setContractTermRange-->', component.get("v.SelectedDepartmentId"));
        var action = component.get('c.getJobsByDepartment');        
        action.setParams({"DepartmentId" : component.get("v.SelectedDepartmentId")});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set('v.JobswrapperClass',response.getReturnValue());
            }else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.resultMessage","Error message: "+errors[0].message);
                    }
                } else {
                    component.set("v.resultMessage","Unknown error");
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
    },
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
        var JobId = event.getSource().get("v.name");
        var action = component.get('c.getJobApplicationInfo');        
        action.setParams({"jobId" : JobId});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set('v.JobapplicationList',response.getReturnValue());
            }else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.resultMessage","Error message: "+errors[0].message);
                    }
                } else {
                    component.set("v.resultMessage","Unknown error");
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
   },
 
   closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   },

 
})