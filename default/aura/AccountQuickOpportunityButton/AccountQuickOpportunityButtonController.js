/**
 * Created by marekhaken on 14.04.2021.
 */

({
    doInit: function(component, event, helper) {
        var list = "[{'label': 'Sales', 'value': 'option1'},{'label': 'Force', 'value': 'option2'}]";
        component.set('v.availableRecordTypes', list);
        var action = component.get('c.getAvailableOptions');

        action.setParams({ recId : component.get('v.recordId'), userId : '' });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set('v.showSpinner', false);

            if (state === "SUCCESS") {
                //console.log(response.getReturnValue());
                var returnvalue = response.getReturnValue();
                if(returnvalue != null){
                    try{
                        var availableRecordTypes = [];

                        var availableConfigs = JSON.parse(returnvalue);
                        component.set('v.json', returnvalue);
                        availableConfigs.forEach(function (cf) {
                            //console.log(cf);

                            //Order by RecordTypeLabels --> old version
                            //var rt = {'label' : cf.RecordTypeLabel, 'value' : cf.RecordTypeId};
                            //Order by Scenario Name --> new version
                            var rt = {'label' : cf.ScenarioName + ': \n'+cf.ScenarioDescription+'', 'value' : cf.ScenarioName+'&+&'+cf.RecordTypeId};

                            //Check if array has this recordtype...
                            var exist = false;
                            availableRecordTypes.forEach(function (ar) {
                                if(ar.value == rt.value){
                                    exist = true;
                                }
                            });

                            if(exist == false){
                                availableRecordTypes.push(rt);
                            }
                        });

                        //console.log('------');
                        //console.log(availableRecordTypes);
                        component.set("v.optionsList",availableRecordTypes);


                    }catch(e){
                        //Vypsat chybovou hlášku!
                    }
                }
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    selectedRecordType: function(component, event, helper) {
        component.set('v.showError', false);
        var selectedRT = event.getParam("value");
        //alert(selectedRT);

        //Nové řešení
        var res = selectedRT.split("&+&");
        selectedRT = res[0];
        component.set('v.scenarioName', selectedRT);

        var obj = {'fieldName' : 'RecordTypeId', 'value' : res[1]};
        var obj2 = {'fieldName' : 'AccountId', 'value' : component.get('v.recordId')};
        var objList = [];
        objList.push(obj);
        objList.push(obj2);
        var jsonObj = JSON.stringify(objList);
        component.set('v.selectedValues', jsonObj);
        component.set('v.fields', null);

        var fieldList = [];
        var jsonString = component.get('v.json');
        var availableConfigs = JSON.parse(jsonString);
        var finalList = [];
        //console.log(jsonString);
        //console.log(availableConfigs);
        var selectedValues = JSON.parse(component.get('v.selectedValues'));

        availableConfigs.forEach(function (cf) {
            //console.log(cf);

            //Staré řešení
            //if(cf.RecordTypeId == selectedRT){
            //Nové řešení
            if(cf.ScenarioName == selectedRT){
                var fieldLabel = cf.FieldLabel;
                var fieldName = cf.FieldName;

                var value = cf.Value;
                if(value == null){
                    value = '-';
                }
                var val = {'fieldName' : fieldName, 'value' : cf.Value, 'fieldLabel' : fieldLabel};
                var myJSON = JSON.stringify(val);

                var exists = false;
                for(var i in finalList){
                    if(finalList[i].question == fieldLabel){
                        //Ve final listu už je toto pole!
                        var answersFromList = finalList[i].answers;
                        var a = {'label' : value, 'value' : myJSON};
                        answersFromList.push(a);
                        finalList[i].answers = answersFromList;
                        exists = true;
                    }
                }

                if(exists == false){
                    //Nová varianta!!!
                    var object = {'fieldName' : fieldName, 'value' : cf.Value, 'fieldLabel' : fieldLabel};
                    selectedValues.push(object);

                    //Stará varianta
                    var answers = [];
                    var a = {'label' : value, 'value' : myJSON};
                    answers.push(a);
                    var ques = {'question' : fieldLabel, 'answers' : answers};
                    finalList.push(ques);
                    fieldList.push(fieldLabel);
                    component.set('v.fields', JSON.stringify(fieldList));
                }

            }
        });
        //console.log(finalList);

        //Nová varianta
        component.set('v.selectedValues', JSON.stringify(selectedValues));

        //Stará variant
        component.set("v.Questions", finalList);
    },
    selectedVal: function(component, event, helper) {
        component.set('v.showError', false);
        var obj = JSON.parse(event.getParam('value'));
        /*
        console.log(obj);
        console.log(obj.value);
        console.log(obj.fieldName);
        console.log(obj.fieldLabel);
        */

        var selectedValues = JSON.parse(component.get('v.selectedValues'));
        var exists = false;
        for(var i in selectedValues){
            if(selectedValues[i].fieldName == obj.fieldName ){
                selectedValues[i].value = obj.value;
                exists = true;
            }
        }

        if(!exists){
            var object = {'fieldName' : obj.fieldName, 'value' : obj.value, 'fieldLabel' : obj.fieldLabel};
            selectedValues.push(object);
        }

        component.set('v.selectedValues', JSON.stringify(selectedValues));
    },
    btnClick: function(component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.disabledBtn', true);
        component.set('v.showError', false);
        var objList = JSON.parse(component.get('v.selectedValues'));
        //console.log(objList);

        var requiredFields = JSON.parse(component.get('v.fields'));
        var insertedFields = [];
        if(objList != null){
            objList.forEach(function (obj) {
                insertedFields.push(obj.fieldLabel);
            });
        }

        var errorMessage = 'Required Fields are not filled:';
        var showError = false;
        requiredFields.forEach(function (f) {
            if(!insertedFields.includes(f)){
                errorMessage += ' '+f;
                showError = true;
            }
        });
        component.set('v.showError', showError);
        component.set('v.errorMessage', errorMessage);

        if(!showError){
            //Call APEX and insert Opportunity
            var jsonString = component.get('v.selectedValues');

            var action = component.get("c.insertOpportunity");
            //Stará varianta
            //action.setParams({ jsonString : jsonString });
            //Nová varianta
            action.setParams({ jsonString : jsonString, 'scenario' : component.get('v.scenarioName')});

            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set('v.showSpinner', false);
                component.set('v.disabledBtn', false);

                if (state === "SUCCESS") {
                    //alert("From server: " + response.getReturnValue());
                    if(response.getReturnValue().startsWith('006')){
                        var toastEvent = $A.get("e.force:showToast");

                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        var message = 'Zpráva';
                        toastEvent.setParams({
                            title: 'Success',
                            type: 'Success',
                            message: 'Opportunity created. You can find it',
                            messageTemplate: 'Opportunity created. You can find it {0} {1}.',
                            messageTemplateData: [
                                message.text,
                                {
                                    url: '',
                                    label: 'here',
                                    executionComponent: {
                                        descriptor: "markup://force:navigateToSObject",
                                        attributes: {recordId: response.getReturnValue(), slideDevName:"detail"},
                                        isEvent: true,
                                        isClientSideCreatable: true,
                                        componentName: 'navigateToSObject'
                                    }
                                }
                            ]
                        });
                        toastEvent.fire();
                    }else{
                        component.set('v.showError', true);
                        component.set('v.errorMessage', response.getReturnValue());
                    }
                }
                else if (state === "INCOMPLETE") {

                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                     errors[0].message);
                            component.set('v.showError', true);
                            component.set('v.errorMessage', errors[0].message);

                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    btnClose: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
});