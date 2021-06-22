$j = jQuery.noConflict();

var device;

$j(document).ready(function () {
    if(screen.width < 760){
        device = 'mobile';
    } else if(screen.width < 1300){
        device = 'tablet';
        if(screen.height > 801){
            device = 'tablet+';
        }
        if(screen.height > 1025){
            device = 'tablet++';
        }
    }else {
        device = 'desktop';
    }

    var language = getLanguageName();
    if(language == 'Russia') {
        $j('#liveAgentChatLog').css('border-top','1px solid #4fcfcc');
    }

    setupFileTransfer(language);

    var chatLogBlock = $j('#liveAgentChatLog');
    chatLogBlock.bind('DOMSubtreeModified', function(){
         var elements = document.getElementsByClassName('name');
         for (var i = 0; i < elements.length; i++) {
             if (language.toUpperCase() == 'RUSSIA'){
                 if( elements[i].innerHTML.indexOf("FLEETCOR:") != -1) {
                     elements[i].innerHTML = elements[i].innerHTML.replace('FLEETCOR:','ППР');
                 }
                 if( elements[i].innerHTML.indexOf("Вы:") != -1) {
                     elements[i].innerHTML = elements[i].innerHTML.replace('Вы:','Вы');
                 }

                 if((elements[i].innerHTML.indexOf("customDateTime") == -1) && (elements[i].innerHTML.indexOf("<strong") != -1)) {
                    var currentDate = new Date();
                    var hours = currentDate.getHours();
                    var minutes = currentDate.getMinutes();
                    minutes = minutes < 10 ? '0' + minutes : minutes;
                    var strTime = hours + ':' + minutes;
                    elements[i].innerHTML = elements[i].innerHTML + ' <span class="customDateTime" style="display: inline">' + strTime + ' </span>'  ;
                 }
             }
             else {
                if( elements[i].innerHTML.indexOf("Fleetcor:") != -1) {
                    elements[i].innerHTML = elements[i].innerHTML.replace('Fleetcor:','Fleetcor');
                }
                if( elements[i].innerHTML.indexOf("You:") != -1) {
                    elements[i].innerHTML = elements[i].innerHTML.replace('You:','You');
                }
                if((elements[i].innerHTML.indexOf("customDateTime") == -1) && (elements[i].innerHTML.indexOf("<strong") != -1)) {
                    var currentDate = new Date();
                    var hours = currentDate.getHours();
                    var minutes = currentDate.getMinutes();
                    var ampm = hours >= 12 ? 'PM' : 'AM';
                    hours = hours % 12;
                    hours = hours ? hours : 12; // the hour '0' should be '12'
                    minutes = minutes < 10 ? '0' + minutes : minutes;
                    var strTime = hours + ':' + minutes + ' ' + ampm;
                    elements[i].innerHTML = elements[i].innerHTML + ' <span class="customDateTime" style="display: inline">' + strTime + ' </span>'  ;
                }
             }
         }

         if(language != 'Russia'){
             var liveAgentChatLog = document.getElementById('liveAgentChatLog');
             var systemElements = liveAgentChatLog.getElementsByClassName('system');
             if (systemElements[0] != null){
                  $j('#liveAgentChatLog').height(295);
             }
         }
    });

    var elementBody = $j('#liveAgentMessageContainer');
    elementBody.bind('DOMSubtreeModified', function(){
        var element = document.getElementById('liveAgentMessageContainer');
        if(element.innerHTML != ''){
             $j('#liveAgentChatLog').height(295);
        }
    });

    var inputFile = $j('#fileTransferForm');
    inputFile.bind('DOMSubtreeModified', function(){
         var sendButton = document.getElementById('fileSendButton');
         document.getElementById('fileSelectInput').style.display ='none';
         var customInput = document.getElementById('customInput');
         var chatLog = document.getElementById('liveAgentChatLog');
         if (sendButton.style.display != 'none'){
             chatLog.style.height = '175px';
             customInput.style.display = 'block';
         }
         else{
             chatLog.style.height = '245px';
             customInput.style.display = 'none';
         }
    });

    if (device == 'mobile'){
         $j('#liveAgentChatLog').height(screen.height*0.5 - 150);
    } else if (device == 'tablet') {
         $j('#liveAgentChatLog').height(screen.height*0.5 - 225);
    } else if (device == 'tablet+') {
         $j('#liveAgentChatLog').height(screen.height*0.5 - 265);
    } else if (device == 'tablet++') {
         $j('#liveAgentChatLog').height(screen.height*0.5 - 400);
    } else {
        $j('.liveAgentSendButton').hide();
        $j('#liveAgentChatTextArea').focus(function(event){
            if( !$j(event.relatedTarget).hasClass('liveAgentSendButton') ){
                $j('#liveAgentChatLog').height($j('#liveAgentChatLog').height()-20);
                $j('.liveAgentSendButton').show();
            };
        });
        $j('#liveAgentChatTextArea').focusout(function(event){
            if( !$j(event.relatedTarget).hasClass('liveAgentSendButton') ){
                $j('#liveAgentChatLog').height($j('#liveAgentChatLog').height()+20);
                $j('.liveAgentSendButton').hide();
            }
        });
        $j('.liveAgentSendButton').focusout(function(event){
            if( !$j(event.relatedTarget).hasClass('liveAgentChatTextArea') ){
                $j('#liveAgentChatLog').height($j('#liveAgentChatLog').height()+20);
                $j('.liveAgentSendButton').hide();
            }
        });
    }

    $j(".liveAgentSendButton").mousedown(function() {
        return false;
    });

    $j('.liveAgentEndButton').on('click', function () {
         $j(this).attr('style','display: none !important');
    });
});

function getLanguageName(){
    var url = new URL(window.location.href);
    var language = url.searchParams.get("language");
    return language;
}

function setupFileTransfer(language){
    var liveAgentFileTransfer = document.getElementById('liveAgentChatFileTransfer');
    if (liveAgentFileTransfer != null){
        if(language == 'Germany'){
            liveAgentFileTransfer.innerHTML = '<label id="customInput" style="display:none" for="fileSelectInput"> <div class="custom-input-label">' +
                                              'Datei wählen </div> </label>' + liveAgentFileTransfer.innerHTML;
        } else if (language == 'Russia'){
            liveAgentFileTransfer.innerHTML = '<label id="customInput" style="display:none" for="fileSelectInput"> <div class="custom-input-label">' +
                                              'Selecteer bestand </div> </label>' + liveAgentFileTransfer.innerHTML;
        } else if (language == 'Netherlands'){
            liveAgentFileTransfer.innerHTML = '<label id="customInput" style="display:none" for="fileSelectInput"> <div class="custom-input-label">' +
                                              'Selecteer bestand </div> </label>' + liveAgentFileTransfer.innerHTML;
        } else if (language == 'Belgium-NL'){
            liveAgentFileTransfer.innerHTML = '<label id="customInput" style="display:none" for="fileSelectInput"> <div class="custom-input-label">' +
                                              'Выбрать файл </div> </label>' + liveAgentFileTransfer.innerHTML;
        } else if (language == 'Belgium-FR'){
            liveAgentFileTransfer.innerHTML = '<label id="customInput" style="display:none" for="fileSelectInput"> <div class="custom-input-label">' +
                                              'Sélectionner un fichier </div> </label>' + liveAgentFileTransfer.innerHTML;
        } else {
            liveAgentFileTransfer.innerHTML = '<label id="customInput" style="display:none" for="fileSelectInput"> <div class="custom-input-label">' +
                                                          'Select a file </div> </label>' + liveAgentFileTransfer.innerHTML;
        }
    }
}

function setDomainEvent(domains){
    var arrayDomains = domains.replace('[','').replace(']','').split(' ').join('');
    arrayDomains = arrayDomains.split(',');
    window.addEventListener('message', function(event) {
        if(event.data == 'closeChatFLEETCOR'){
            var origin = false;
            for(var i=0; i<arrayDomains.length; i++){
               if (~event.origin.indexOf(arrayDomains[i])) {
                   origin = true;
                   break;
               }
            }
            if (origin) {
                SfdcApp.LiveAgent.Chasitor.endChat();
            } else {
                console.log('Chat Error #1');
                return;
            }
        }
    });
}