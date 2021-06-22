public with sharing class E2EChatPageCtrl {

    public Map<String, LongFormPage> pageMapChat {get; set;}
    public String clientNameLabel{get;set;}
    public String lang{get;set;}
    public List<String> domainURLs {get;set;}

    public  E2EChatPageCtrl(){
        getDomainURLs();
        String countryParam = (ApexPages.currentPage().getParameters().get('language')).toUpperCase();
        countryParam = countryParam.replace('#','');
        LFChatService chatService = new LFChatService();
        if(countryParam == 'GERMANY'){
            lang = 'de';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else if (countryParam == 'NETHERLANDS'){
            lang = 'nl_NL';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else if (countryParam == 'BELGIUM-NL'){
            lang = 'nl_BE';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else if (countryParam == 'BELGIUM-FR'){
            lang = 'fr';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else if(countryParam == 'RUSSIA'){
            lang = 'ru';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'Вы';
        }
        else if(countryParam == 'POLAND'){
            lang = 'pl';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'Jesteś';
        }
        else if(countryParam == 'FRANCE'){
            lang = 'fr';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else if(countryParam == 'HUNGARY'){
            lang = 'hu';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else if (countryParam == 'SWITZERLAND-DE') {
            lang = 'de';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else if (countryParam == 'SWITZERLAND-FR') {
            lang = 'fr';
            chatService.setPageMap(countryParam);
            this.pageMapChat = chatService.getPagesMap();
            clientNameLabel = 'You';
        }
        else {
            lang = 'en_US';
            clientNameLabel = 'You';
        }
    }

    public void getDomainURLs(){
        domainURLs = new List<String>();
        domainURLs.add('force.com');
        for(Domain currentDomain : [SELECT Domain FROM Domain ]){
            domainURLs.add(currentDomain.Domain);
        }
    }
}