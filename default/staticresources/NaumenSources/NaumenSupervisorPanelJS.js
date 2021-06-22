$js = jQuery.noConflict();
        var NaumenSupervisorApp = angular.module('NaumenSupervisorApp', []);
        NaumenSupervisorApp.controller('NaumenSupervisorController', function($scope) {
            $scope.init = function (userProfile) {
                console.log('>> init >> profile : ' + userProfile);
                $scope.userProfile = userProfile;
                $scope.clearSelectedFiltersData();
                $scope.clearSearchResults();
                $scope.setPicklist_disqualReasons();
                $scope.setPicklist_industries();
                $scope.checkRecordAccess = true;
            }
            $scope.setSetupData = function (setupData) {
                $scope.setPicklist_statuses(setupData.statuses);
                $scope.setPicklist_leadSourses(setupData.leadSourses);
                $scope.setPicklist_excludedNaumenProjects(setupData.naumenProjects);
                $scope.setPicklist_naumenProjects(setupData.naumenProjects);
                $scope.setPicklist_orgTypes(setupData.orgTypes);
                $scope.setPicklist_promocodes(setupData.promocodes);
                $scope.setPicklist_regions(setupData.regions);
            }
            // set options for "statuses" picklist
            $scope.setPicklist_statuses = function (optionsDataList) {
                console.log('>> in >> setPicklist_statuses : user : ' + $scope.userProfile);
                var htmlText = '';
                if ($scope.userProfile == 'System Administrator') {
                    // get data from controller (metadata api)
                    htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedStatuses);
                } else {
                    // get data from vf (standard sf picklist)
                    optionsDataList = {};
                    var optionsParams = $scope.getOptionsParams();                    
                    if (optionsParams.showLeadsData) {
                        var options_Lead = $js('.ruLeadStatuses > option');
                        for (i = 0; i < options_Lead.length; i++) {
                            var option = options_Lead[i];
                            if ($js(option).val() == 'Moved to Start') continue;
                            var optionData = $scope.getOptionData($js(option).val(), $js(option).text());
                            if (optionData != null) optionsDataList[optionData.optionVal] = optionData.optionText;
                        }
                    }
                    if (optionsParams.showOppsData) {
                        var options_Opp = $js('.ruOppStages > option');
                        for (i = 0; i < options_Opp.length; i++) {
                            var option = options_Opp[i];
                            if ($js(option).val() == 'Moved to Start') continue;
                            var optionData = $scope.getOptionData($js(option).val(), $js(option).text());
                            if (optionData != null) optionsDataList[optionData.optionVal] = optionData.optionText;
                        }
                    }
                    htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedStatuses);
                }
                document.getElementById('statuses').innerHTML = htmlText;
                $js('#statuses').selectpicker('refresh');
            }
            // set options for "disqualReasons" picklist
            $scope.setPicklist_disqualReasons = function () {
                console.log('>> in >> setPicklist_disqualReasons');
                var optionsDataList = {};
                // add disqualReasons (get from leads)
                var options = $js('.ruLeadDisqualReasons > option');
                for (i = 0; i < options.length; i++) {
                    var option = options[i];
                    var optionData = $scope.getOptionData($js(option).val(), $js(option).text());
                    if (optionData != null) optionsDataList[optionData.optionVal] = optionData.optionText;
                }
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedDisqualReasons);
                document.getElementById('disqualReasons').innerHTML = htmlText;
                $js('#disqualReasons').selectpicker('refresh');
            }
            // set options for "orgTypes" picklist
            $scope.setPicklist_orgTypes = function () {
                console.log('>> in >> setPicklist_orgTypes');
                
                var optionsDataList = {};
                var optionsParams = $scope.getOptionsParams();                    
                if (optionsParams.showLeadsData) {
                    var options_Lead = $js('.ruLeadOrgTypes > option');
                    for (i = 0; i < options_Lead.length; i++) {
                        var option = options_Lead[i];
                        var optionData = $scope.getOptionData($js(option).val(), $js(option).text());
                        if (optionData != null) optionsDataList[optionData.optionVal] = optionData.optionText;
                    }
                }
                if (optionsParams.showOppsData) {
                    var options_Opp = $js('.ruAccOrgTypes > option');
                    for (i = 0; i < options_Opp.length; i++) {
                        var option = options_Opp[i];
                        var optionData = $scope.getOptionData($js(option).val(), $js(option).text());
                        if (optionData != null) optionsDataList[optionData.optionVal] = optionData.optionText;
                    }
                }
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedOrgTypes);
                document.getElementById('orgTypes').innerHTML = htmlText;
                $js('#orgTypes').selectpicker('refresh');
                
            }
            // set options for "leadSourses" picklist
            $scope.setPicklist_leadSourses = function (optionsDataList) {
                console.log('>> in >> setPicklist_leadSourses');
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedLeadSources);
                document.getElementById('leadSourses').innerHTML = htmlText;
                $js('#leadSourses').selectpicker('refresh');
            }
            // set options for "excludedNaumenProjects" picklist
            $scope.setPicklist_excludedNaumenProjects = function (optionsDataList) {
                console.log('>> in >> setPicklist_excludedNaumenProjects');
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedExcludedNaumenProjects);
                document.getElementById('excludedNaumenProjects').innerHTML = htmlText;
                $js('#excludedNaumenProjects').selectpicker('refresh');
            }
            // set options for "naumenProjects" picklist
            $scope.setPicklist_naumenProjects = function (optionsDataList) {
                console.log('>> in >> setPicklist_naumenProjects');
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedProjectUUID);
                document.getElementById('naumenProjects').innerHTML = htmlText;
                $js('#naumenProjects').selectpicker('refresh');
            }
            // set options for "promocodes" picklist
            $scope.setPicklist_promocodes = function (optionsDataList) {
                console.log('>> in >> setPicklist_promocodes');
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedPromocodes);
                document.getElementById('promocodes').innerHTML = htmlText;
                $js('#promocodes').selectpicker('refresh');
            }
            // set options for "promocodes" picklist
            $scope.setPicklist_regions = function (optionsDataList) {
                console.log('>> in >> setPicklist_regions');
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedRegions);
                document.getElementById('regions').innerHTML = htmlText;
                $js('#regions').selectpicker('refresh');
            }
            // set options for "industries" picklist
            $scope.setPicklist_industries = function () {
                console.log('>> in >> setPicklist_industries');
                var optionsDataList = [];
                // add industries (get from leads)
                var options = $js('.ruLeadIndustries > option');
                for (i = 0; i < options.length; i++) {
                    var option = options[i];
                    var optionData = $scope.getOptionData($js(option).val(), $js(option).text());
                    if (optionData != null) optionsDataList[optionData.optionVal] = optionData.optionText;
                }
                var htmlText = $scope.addOptionsHTMLFromList (optionsDataList, $scope.selectedIndustries);
                document.getElementById('industries').innerHTML = htmlText;
                $js('#industries').selectpicker('refresh');
            }

            $scope.addOptionsHTMLFromList = function (optionsDataList, selectedValuesArr) {
                var htmlText = '';
                var optionsValues = Object.keys(optionsDataList);
                for (i = 0; i < optionsValues.length; i++) {
                    var optionVal = optionsValues[i];
                    var optionText = optionsDataList[optionVal];
                    htmlText += $scope.addOptionHTML (optionVal, optionText, selectedValuesArr);
                }
                return htmlText;
            }
            $scope.addOptionHTML = function (optionVal, optionText, selectedValuesArr) {
                var htmlText = '';
                var isSelected = selectedValuesArr.includes(optionVal);
                htmlText += '<option ';
                if (isSelected) htmlText += 'selected="selected" ';
                htmlText += 'value="'+optionVal+'" ';
                htmlText += '>'+optionText+'</option>';
                return htmlText;
            }
            $scope.getOptionData = function (optionVal, optionText) {
                if (optionVal != '') {
                    var optionData = {};
                    optionData.optionVal = optionVal;
                    optionData.optionText = optionText.replace("'", "\'");
                    return optionData;
                } 
                return null;
            }
            function htmlDecode(htmlText) {
                var doc = new DOMParser().parseFromString(htmlText, "text/html");
                return doc.documentElement.textContent;
              }
            $scope.clearPicklistSelectedValues = function (picklistId) {
                $js('#'+picklistId).val('default');
                $js('#'+picklistId).selectpicker("refresh");
            }
            // get options params - which sobj types options to show
            $scope.getOptionsParams = function () {
                var optionsParams = {};
                optionsParams.showLeadsData = false;
                optionsParams.showOppsData = false;
                if ($scope.selectedSObjTypes.length == 0) return optionsParams;
                for (i = 0; i < $scope.selectedSObjTypes.length; i++) {
                    var selectedItemValue = $scope.selectedSObjTypes[i];
                    if (selectedItemValue == 'Lead') optionsParams.showLeadsData = true;
                    if (selectedItemValue == 'Opportunity') optionsParams.showOppsData = true;
                }
                return optionsParams;
            }
        // ------- on change picklist values processing -------
        // "sObjTypes" select onchange
            $scope.onSelectSObjType = function () {
                console.log('>> onSelectSObjType >> ', $scope.selectedSObjTypes);
                var optionsParams = $scope.getOptionsParams();
                if ($scope.selectedSObjTypes.length > 0) {
                    $scope.getSetupData();
                    $js('.filter-wrap').addClass('show-filter');
                    //refresh picklists
                    $scope.setPicklist_statuses(optionsParams.showLeadsData, optionsParams.showOppsData); // show statuses for the selected sobject type
                } else {
                    $js('.filter-wrap').removeClass('show-filter');
                    $js('#disqualReasonsBlock').css('display', 'none');
                    $js('li.selected:has(> a.leads)').removeClass('selected');
                    $scope.refreshSelectedFiltersData();
                }
                if (!optionsParams.showLeadsData) { // clear leads picklists
                    $scope.clearPicklistSelectedValues('leadSourses');
                }
                setLabels();
            }
        // "statuses" select onchange 
            $scope.onSelectStatuses = function () {
                console.log('>> onSelectStatuses >> ', $scope.selectedStatuses);
            // show/hide disqual reasons
                var showDisqualReasons = false;
                for (i = 0; i < $scope.selectedStatuses.length; i++) {
                    var selectedItemValue = $scope.selectedStatuses[i];
                    if (selectedItemValue == 'Disqualified' || selectedItemValue == 'Отказ') showDisqualReasons = true;
                }
                var displayDisqualReasons = showDisqualReasons ? 'block' : 'none';
                    $js('#disqualReasonsBlock').css('display', displayDisqualReasons);
                    
                if (showDisqualReasons) {
                    var inHTML = document.getElementById('disqualReasons').innerHTML.replace(/\s/g,'')
                    if (inHTML == '') $scope.setPicklist_disqualReasons();
                } else {
                    $scope.clearPicklistSelectedValues('disqualReasons');
                    $scope.selectedDisqualReasons = [];
                }
            }
            $scope.refreshSelectedFiltersData = function () {
                console.log('>> in >> refreshSelectedFiltersData');
                $scope.clearPicklistSelectedValues('excludedNaumenProjects');
                $scope.clearPicklistSelectedValues('promocodes');
                $scope.clearPicklistSelectedValues('statuses');
                $scope.clearPicklistSelectedValues('disqualReasons');
                $scope.clearPicklistSelectedValues('orgTypes');
                $scope.clearPicklistSelectedValues('regions');
                $scope.clearPicklistSelectedValues('industries');
                $scope.expectedVolume_from = '';
                $scope.expectedVolume_to = '';
                $scope.ratingFSNew_from = '';
                $scope.ratingFSNew_to = '';
                $scope.ratingFS_from = '';
                $scope.ratingFS_to = '';
                $scope.clearSelectedFiltersData();
            }
            $scope.clearSelectedFiltersData = function () {
            // lists of selected values in picklists
                $scope.selectedSObjTypes = [];
                $scope.selectedExcludedNaumenProjects = [];
                $scope.selectedPromocodes = [];
                $scope.selectedStatuses = [];
                $scope.selectedDisqualReasons = [];
                $scope.selectedLeadSources = [];
                $scope.selectedOrgTypes = [];
                $scope.selectedRegions = [];
                $scope.selectedIndustries = [];
                $scope.selectedProjectUUID = [];
            // inputs data
                $scope.expectedVolume_from = '';
                $scope.expectedVolume_to = '';
                $scope.ratingFSNew_from = '';
                $scope.ratingFSNew_to = '';
                $scope.ratingFS_from = '';
                $scope.ratingFS_to = '';
            }
            $scope.clearSearchResults = function () {
                $scope.addPreviewData('');
            }
            $scope.addPreviewData = function (previewDataHTML) {
                $js('#previewDataWrap').html(previewDataHTML);
            }
        //-------- CONTROLLER REMOTE FUNCTIONS --------------
            $scope.getSetupData = function () {
                console.log('>>> in >>> getSetupData');
                try {
                    $scope.showOverlay();
                    var optionsParams = $scope.getOptionsParams();

                    Visualforce.remoting.Manager.invokeAction(
                        'Naumen_SupervisorPanelCtrl.getSetupData',
                        JSON.stringify(optionsParams),
                        function(result, event){
                            result = JSON.stringify(result).replace(/&quot;/g, '\\"');
                            result = JSON.parse(result);
                            console.log('event : ', event);
                            if (event.status) {
                                if (result.status == 'ok') {
                                    $scope.setSetupData(result.setupData);
                                    $scope.$apply();
                                    $scope.hideOverlay();
                                } else {
                                    var errHeader = $label_title_ErrorOccurred;
                                    var errMsg = result.message;
                                    $scope.showNotification ('warning', errHeader, errMsg); // show notification to user
                                }
                            } else if (event.type === 'exception') {
                                var errHeader = $label_title_ErrorOccurred;
                                var errMsg = event.message + "; " + event.where;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            } else {
                                var errHeader = $label_Naumen_notifHeader_UnknownError;
                                var errMsg = event.message;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            }
                        }, 
                        {escape: true}
                    );
                } catch (ex) {
                    console.error(ex);
                    $scope.showNotification ('error', 'JS exception', JSON.stringify(ex)); // show notification to user
                }    
                return false;
            }
            $scope.getPreviewData = function (resultAction) {
                console.log('>>> in >>> getPreviewData');
                try {
                    $scope.showOverlay();
                    var filtersData = {};
                    filtersData['sObjTypes'] = $scope.selectedSObjTypes;
                    filtersData['excludedNaumenProjects'] = $scope.selectedExcludedNaumenProjects;
                    filtersData['promocodes'] = $scope.selectedPromocodes;
                    filtersData['statuses'] = $scope.selectedStatuses;
                    filtersData['disqualReasons'] = $scope.selectedDisqualReasons;
                    filtersData['leadSourses'] = $scope.selectedLeadSources;
                    filtersData['orgTypes'] = $scope.selectedOrgTypes;
                    filtersData['regions'] = $scope.selectedRegions;
                    filtersData['industries'] = $scope.selectedIndustries;
                    filtersData['expectedVolume_from'] = $js(expectedVolume_from).val() == '' ? null : parseFloat($js(expectedVolume_from).val());
                    filtersData['expectedVolume_to'] = $js(expectedVolume_to).val() == '' ? null : parseFloat($js(expectedVolume_to).val());
                    filtersData['ratingFSNew_from'] = $js(ratingFSNew_from).val() == '' ? null : parseFloat($js(ratingFSNew_from).val());
                    filtersData['ratingFSNew_to'] = $js(ratingFSNew_to).val() == '' ? null : parseFloat($js(ratingFSNew_to).val());
                    filtersData['ratingFS_from'] = $js(ratingFS_from).val() == '' ? null : parseFloat($js(ratingFS_from).val());
                    filtersData['ratingFS_to'] = $js(ratingFS_to).val() == '' ? null : parseFloat($js(ratingFS_to).val());
                    filtersData['checkRecordAccess'] = $scope.checkRecordAccess;
                    filtersData['projectUUID'] = $scope.selectedProjectUUID;
                    
                    console.log('filtersData : ', JSON.stringify(filtersData));

                    Visualforce.remoting.Manager.invokeAction(
                        'Naumen_SupervisorPanelCtrl.getPreviewData',
                        JSON.stringify(filtersData),
                        function(result, event){
                            result = JSON.stringify(result).replace(/&quot;/g, '\\"');
                            result = JSON.parse(result);
                            console.log('event : ', event);
                            if (event.status) {
                                if (result.status == 'ok') {
                                    $scope.addPreviewData(htmlDecode(result.tablesHTML));
                                    $scope.$apply();
                                    $scope.hideOverlay();
                                } else {
                                    var errHeader = $label_title_ErrorOccurred;
                                    var errMsg = result.message;
                                    $scope.showNotification ('warning', errHeader, errMsg); // show notification to user
                                }
                            } else if (event.type === 'exception') {
                                var errHeader = $label_title_ErrorOccurred;
                                var errMsg = event.message + "; " + event.where;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            } else {
                                var errHeader = $label_Naumen_notifHeader_UnknownError;
                                var errMsg = event.message;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            }
                            
                            if (resultAction != null) resultAction();
                        }, 
                        {escape: true}
                    );
                } catch (ex) {
                    console.error(ex);
                    $scope.showNotification ('error', 'JS exception', JSON.stringify(ex)); // show notification to user
                }    
               return false;
            }
            $scope.uploadToExcel = function () {
                console.log('>>> in >>> uploadToExcel');
                try {
                    $scope.showOverlay();
                    var filtersData = {};
                    filtersData['sObjTypes'] = $scope.selectedSObjTypes;
                    filtersData['excludedNaumenProjects'] = $scope.selectedExcludedNaumenProjects;
                    filtersData['promocodes'] = $scope.selectedPromocodes;
                    filtersData['statuses'] = $scope.selectedStatuses;
                    filtersData['disqualReasons'] = $scope.selectedDisqualReasons;
                    filtersData['leadSourses'] = $scope.selectedLeadSources;
                    filtersData['orgTypes'] = $scope.selectedOrgTypes;
                    filtersData['regions'] = $scope.selectedRegions;
                    filtersData['industries'] = $scope.selectedIndustries;
                    filtersData['expectedVolume_from'] = $js(expectedVolume_from).val() == '' ? null : parseFloat($js(expectedVolume_from).val());
                    filtersData['expectedVolume_to'] = $js(expectedVolume_to).val() == '' ? null : parseFloat($js(expectedVolume_to).val());
                    filtersData['ratingFSNew_from'] = $js(ratingFSNew_from).val() == '' ? null : parseFloat($js(ratingFSNew_from).val());
                    filtersData['ratingFSNew_to'] = $js(ratingFSNew_to).val() == '' ? null : parseFloat($js(ratingFSNew_to).val());
                    filtersData['ratingFS_from'] = $js(ratingFS_from).val() == '' ? null : parseFloat($js(ratingFS_from).val());
                    filtersData['ratingFS_to'] = $js(ratingFS_to).val() == '' ? null : parseFloat($js(ratingFS_to).val());
                    filtersData['checkRecordAccess'] = $scope.checkRecordAccess;
                    filtersData['projectUUID'] = $scope.selectedProjectUUID;
                    
                    console.log('filtersData : ', JSON.stringify(filtersData));
                    Visualforce.remoting.Manager.invokeAction(
                        'Naumen_SupervisorPanelCtrl.uploadToExcel',
                        JSON.stringify(filtersData),
                        function(result, event){
                            console.log('event : ', event);
                            result = JSON.stringify(result).replace(/&quot;/g, '\\"');
                            result = JSON.parse(result);
                            if (event.status) {
                                if (result.status == 'ok') {
                                    var msgHeader = $label_NaumenSupervisor_notif_uploadExcelSuccess_header;
                                    var msg =  $label_NaumenSupervisor_notif_uploadExcelSuccess_descr;
                                    $scope.showNotification ('success', msgHeader, msg); // show notification to user
                                    $scope.hideOverlay();
                                } else {
                                    var errHeader = $label_title_ErrorOccurred;
                                    var errMsg = result.message;
                                    $scope.showNotification ('warning', errHeader, errMsg); // show notification to user
                                }
                            } else if (event.type === 'exception') {
                                var errHeader = $label_title_ErrorOccurred;
                                var errMsg = event.message + "; " + event.where == null ? '' : event.where;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            } else {
                                var errHeader = $label_Naumen_notifHeader_UnknownError;
                                var errMsg = event.message;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            }                        
                        }, 
                        {escape: true}
                    );
                } catch (ex) {
                    console.error(ex);
                    $scope.showNotification ('error', 'JS exception', JSON.stringify(ex)); // show notification to user
                }    
               return false;
            }

            $scope.getNumberOfRecordsAndUploadToNaumen = function () {
                var isSuccess = $scope.checkFiltersData();
                if (!isSuccess) return;
                $scope.getPreviewData($scope.uploadToNaumen);
            }

            $scope.uploadToNaumen = function () {
                console.log('>>> in >>> uploadToNaumen');
                try {
                    $scope.showOverlay();
                    var filtersData = {};
                    filtersData['sObjTypes'] = $scope.selectedSObjTypes;
                    filtersData['excludedNaumenProjects'] = $scope.selectedExcludedNaumenProjects;
                    filtersData['promocodes'] = $scope.selectedPromocodes;
                    filtersData['statuses'] = $scope.selectedStatuses;
                    filtersData['disqualReasons'] = $scope.selectedDisqualReasons;
                    filtersData['leadSourses'] = $scope.selectedLeadSources;
                    filtersData['orgTypes'] = $scope.selectedOrgTypes;
                    filtersData['regions'] = $scope.selectedRegions;
                    filtersData['industries'] = $scope.selectedIndustries;
                    filtersData['expectedVolume_from'] = $js(expectedVolume_from).val() == '' ? null : parseFloat($js(expectedVolume_from).val());
                    filtersData['expectedVolume_to'] = $js(expectedVolume_to).val() == '' ? null : parseFloat($js(expectedVolume_to).val());
                    filtersData['ratingFSNew_from'] = $js(ratingFSNew_from).val() == '' ? null : parseFloat($js(ratingFSNew_from).val());
                    filtersData['ratingFSNew_to'] = $js(ratingFSNew_to).val() == '' ? null : parseFloat($js(ratingFSNew_to).val());
                    filtersData['ratingFS_from'] = $js(ratingFS_from).val() == '' ? null : parseFloat($js(ratingFS_from).val());
                    filtersData['ratingFS_to'] = $js(ratingFS_to).val() == '' ? null : parseFloat($js(ratingFS_to).val());
                    filtersData['checkRecordAccess'] = $scope.checkRecordAccess;
                    filtersData['projectUUID'] = $scope.selectedProjectUUID;
                    
                    console.log('filtersData : ', JSON.stringify(filtersData));
                    var isSuccess = $scope.checkFiltersData();
                    if (!isSuccess) return;

                    Visualforce.remoting.Manager.invokeAction(
                        'Naumen_SupervisorPanelCtrl.uploadToNaumen',
                        JSON.stringify(filtersData),
                        function(result, event){
                            result = JSON.stringify(result).replace(/&quot;/g, '\\"');
                            result = JSON.parse(result);
                            console.log('event : ', event);

                            if (event.status) {
                                if (result.status == 'ok') {
                                    var msgHeader = $label_NaumenSupervisor_notif_SearchRecordsResult_header;
                                    var msgText = '<p>' + $label_NaumenSupervisor_notif_SearchRecordsResult_descr + '</p>';
                                    $scope.showNotification ('success', msgHeader, msgText); // show notification to user

                                    $scope.$apply();
                                    $scope.hideOverlay();
                                } else {
                                    var errHeader = $label_title_ErrorOccurred;
                                    var errMsg = result.message;
                                    $scope.showNotification ('warning', errHeader, errMsg); // show notification to user
                                }
                            } else if (event.type === 'exception') {
                                var errHeader = $label_title_ErrorOccurred;
                                var errMsg = event.message + "; " + event.where;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            } else {
                                var errHeader = $label_Naumen_notifHeader_UnknownError;
                                var errMsg = event.message;
                                $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                            }                        
                        }, 
                        {escape: true}
                    );
                } catch (ex) {
                    console.error(ex);
                    $scope.showNotification ('error', 'JS exception', JSON.stringify(ex)); // show notification to user
                }    
               return false;
            }
            $scope.checkFiltersData = function () {
                var errMsg = '';
                if ($scope.selectedProjectUUID == null || $scope.selectedProjectUUID.length == 0) errMsg += '"'+$label_label_uploadTo + $label_NaumenProjects__labelPlural+'"';
                if (errMsg != '') errMsg += ', ';
               if (errMsg != '') {
                    var errHeader = $label_NaumenSupervisor_notif_fillInData_header;
                    errMsg = $label_NaumenSupervisor_notif_fillInData_descr + errMsg;
                    $scope.showNotification ('error', errHeader, errMsg); // show notification to user
                    return false;
                }
                return true;
            }
        // ----- MODAL POPUPS FUNCTIONS -----
            $scope.showNotification = function (msgType, msgHeader, msgText) {
                console.log('>> notification >> ' + msgType + ' : ' + msgHeader + ' : ' + msgText);
                $scope.showOverlay();
                $scope.notification = {};
                $scope.notification.type = msgType;
                $scope.notification.headerText = msgHeader;

                var notifBody = document.createElement("p");
                notifBody.style.width="100%";
                notifBody.innerHTML = msgText;
                $js('#notificationDescription').html(notifBody)
                $scope.$apply();
            }
            $scope.closeModal = function () {
                $scope.hideOverlay();
                $scope.notification = null;
            }

        // ----- OVERLAY FUNCTIONS -----
            $scope.showOverlay = function () {
                document.getElementById('overlay').style.display = 'block'; 
            }
            $scope.hideOverlay = function () {
                document.getElementById('overlay').style.display = 'none'; 
            }
        });