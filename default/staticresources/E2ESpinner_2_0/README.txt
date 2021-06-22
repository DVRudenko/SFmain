WAVEOC Spinner

В превью файле представлен ВИЗУАЛЬНЫЙ пример спиннера. В страницу вижуал форс вставляется немного другой код. 

*********
  1.CSS
*********

Вставьте файл spinner.css в хидер страницы.

<apex:stylesheet value="{!URLFOR($Resource.Spinner, 'spinner.css')}"/>

**********
  2. HTML/Visualforce
*********

Сама дивка:

    <div class="splashStatus" id="splashDiv">
        <div class="circle"><img src="{!URLFOR($Resource.Spinner, 'spinner.gif')}"/></div>
        <div class="txt">Please Wait. Loading...</div>
    </div>

В конец файла перед тегом </apex:page> вставить тег:

<div class="lightbox"></div>


Подробнее об использовании статик ресурсов можно почитать по ссылке: http://www.salesforce.com/us/developer/docs/pages/Content/pages_resources.htm

*********
  3. Scripts
*********

Вставьте файлы spinner.js в хидер страницы.

<apex:includeScript value="{!URLFOR($Resource.Spinner, 'spinner.js')}"/>

*********
  4. Action Status
*********

Используйте данный action status:

<apex:actionStatus id="splashStatus" onstart="startSplash();" onstop="endSplash(); "/>



*********
  4. Использование статуса в кнопках, ссылках и тд.
*********

<apex:commandLink action="{!save}" value="Save" status="splashStatus"/>







