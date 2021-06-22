var tabActive = false;
var closeDelay = 40 * 60000;
var closeTimerId;
var saveDelay = 30000;
var saveTimerId;
var lastSavedDescription = '';

$(document).ready(function(){
    //Event to reset active form
    $(document).on('keydown click', function(){ resetInActive(); })
                .mouseout(function(){ resetInActive(); })
                .mouseover(function(){ resetInActive(); });

    resetInActive();
});

function resetInActive(){
    clearTimeout(saveTimerId);
    saveTimerId = setTimeout(saveComments, saveDelay);

    clearTimeout(closeTimerId);
    closeTimerId = setTimeout(userLeaveThePage, closeDelay);
}

function saveComments(){
    //if(tabActive){
    checkDescriptionToSave();
   // }
    clearTimeout(saveTimerId);
    saveTimerId = setTimeout(saveComments, saveDelay);
}

function checkDescriptionToSave(){
    var commentsArea = document.getElementsByClassName('commit_slide_comment');
    var comments = '\n' + '----- Комментарии к презентации ----- :'  + '\n';
    Array.from(commentsArea).forEach((comment) => {
       if(comment.value != undefined && comment.value != ''){
           comments += comment.id + ' --> ' + comment.value + '\n';
       }
    });
    
    var anketa = 'Регионы передвижения: ' + $('#region').val() + '\n';
    anketa += 'Текущий поставщик: ' + $('#postav').val() + '\n';
    anketa += 'Машины в автопарке Легковые: ' + $('#legkovie').val() + '\n';
    anketa += 'Легковые комерческие: ' + $('#legkovie-kom').val() + '\n';
    anketa += 'Грузовые: ' + $('#gruz').val() + '\n';
    anketa += 'Текущие финансовые условия: ' + $('#finans').val() + '\n';
    anketa += 'Банк: ' + $('#bank').val() + '\n';
    anketa += 'ИНН компании: ' + $('#inn').val() + '\n';
    anketa += 'Кол-во карт: ' + $('#cards').val() + '\n';
    anketa += 'Выбранный тариф: ' + $('#tarif').val() + '\n';
    anketa += 'Почтовый адрес: ' + $('#pochta').val() + '\n';
    anketa += 'Телефон: ' + $('#tel').val() + '\n';
    anketa += 'Электронная почта: ' + $('#pochta2').val() + '\n';
    
    var description = comments + '\n' + anketa;
    if(description != lastSavedDescription){
        lastSavedDescription = description;
        asyncSaveComment(description);
    }
}

function userLeaveThePage(){
    setTimeout(redirectToOppListView, 4000);
}

function redirectToOppListView(){
    window.location = '/006/o';
}