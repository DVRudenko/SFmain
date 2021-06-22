public class LFChatService {
    public String chatButtonId;
    public String chatDeploymentId;
    public String chatDeploymentJsURL;
    public String chatURL;
    public String country;

    private Map<String, LongFormPage> pageMapChat;
    private LiveChatVisitor newVisitor;
    private LiveChatTranscript newChat;

    /*******************************************************************************
    *  Name            : setChatDefaultSettings
    *  Summary         : set default settings for chat
    *  CreatedDate     : 18.04.2018
    *  ModifiedDate    : -
    *  Parameters      : String country
    *  Returns         : -
    ******************************************************************************/
    public void setChatDefaultSettings(String countryName){
        if (countryName != null && E2E_Chat_Setup__c.getValues(countryName) != null) {
            chatButtonId =  E2E_Chat_Setup__c.getValues(countryName).chatButtonId__c;
            chatDeploymentId =  E2E_Chat_Setup__c.getValues(countryName).chatDeploymentId__c;
            chatDeploymentJsURL = E2E_Chat_Setup__c.getValues(countryName).DeploymentJS__c;
            chatURL =  E2E_Chat_Setup__c.getValues(countryName).chatURL__c;
            country = countryName;
        }
    }

    /*******************************************************************************
    *  Name            : setPageMap
    *  Summary         : set page map for chat
    *  CreatedDate     : 18.04.2018
    *  ModifiedDate    : -
    *  Parameters      : String country
    *  Returns         : -
    ******************************************************************************/
    public void setPageMap(String Country) {
        Map<Id, LongForm_Page__c> lfPagesMap = new Map<Id, LongForm_Page__c>([
                SELECT Name, Type__c, Long_Form__c
                FROM LongForm_Page__c
                WHERE Long_Form__r.Country__c = :Country AND
                Name = 'CHAT'
                LIMIT 10000
        ]);

        List<LongForm_Element__c> elementsList = [
                SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c,
                (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
                FROM LongForm_Element__c
                WHERE Long_Form_Page__c IN :lfPagesMap.keySet()
                LIMIT 10000
        ];

        pageMapChat = new Map<String, LongFormPage>();
        Set<String> fieldTypes = new Set<String>{'Text Field', 'Picklist Field', 'Radio-button Field', 'Checkbox Field', 'Slider Field'};
        for (LongForm_Element__c element : elementsList) {
            if (! pageMapChat.containsKey(element.Long_Form_Page__r.Name) ) {
                pageMapChat.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pageMapChat.get(element.Long_Form_Page__r.Name).pageTitle = element.Long_Form_Page__r.Title__c;
                pageMapChat.get(element.Long_Form_Page__r.Name).systemError = element.Long_Form_Page__r.System_Error__c;
                pageMapChat.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongFormElementItem>>();
                pageMapChat.get(element.Long_Form_Page__r.Name).fields = new Map<String, LongFormField>();
            }

            if (fieldTypes.contains(element.Type__c) && ! element.Long_Form_Element_Items__r.isEmpty()) {
                LongFormField field = new LongFormField();
                field.options = new List<SelectOption>();
                field.elementItemsMap = new Map<String, LongFormElementItem>();
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    if (elementItem.Type__c == 'Options') {
                        lfElementItem.value = elementItem.Value__c.deleteWhitespace();
                        lfElementItem.value = elementItem.Value__c.replaceAll('_', ' ');

                        List<String> optionsList = elementItem.Value__c.split(';');
                        for (String option : optionsList) {
                            option = option.trim();
                            field.options.add(new SelectOption(option.substringBefore('=>'), option.substringAfter('=>')));
                        }
                    }
                    field.elementItemsMap.put(elementItem.Name, lfElementItem);
                }
                pageMapChat.get(element.Long_Form_Page__r.Name).fields.put(element.Name, field);
            } else {
                if (! pageMapChat.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name) ) {
                    pageMapChat.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongFormElementItem>());
                }
                for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                    LongFormElementItem lfElementItem = new LongFormElementItem();
                    lfElementItem.value = elementItem.Value__c;
                    pageMapChat.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, lfElementItem);
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : getFirstChatMessage
    *  Summary         : prepare and return chat first message string
    *  CreatedDate     : 18.04.2018
    *  ModifiedDate    : 03.06.2019
    *  Parameters      : String country,Integer activeStep,String activeSubStep,String clientNameToChat
    *  Returns         : String chatFirstMessage
    ******************************************************************************/
    public String getFirstChatMessage(String country,Integer activeStep,String activeSubStep,String clientNameToChat){
        String chatFirstMessage = '';
        if(country == 'Germany'){
            if(activeStep == 0){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie vielleicht Hilfe?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe Ihr Unternehmen anzugeben?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung bei der Angabe Ihres Verbrauchs?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe das richtige Angebot zu finden?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei der Einrichtung Ihrer Karten?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe Ihr Unternehmen anzugeben?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei der Einrichtung Ihrer Karten?';
            }
            else if (activeStep == 3){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe beim Umweltschutz-Programm?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei den Zahlungsoptionen?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung?';
            }
            else {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung?';
            }
        }

        else if(country == 'Netherlands'){
            if(activeStep == 0){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij de informatie over uw bedrijf?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het melden van uw verbruik?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het vinden van de juiste aanbieding?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het instellen van uw passen?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij de informatie over uw bedrijf ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het instellen van uw passen?';
            }
            else if (activeStep == 3){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het milieubeschermingsprogramma?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij de betalingsopties?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig?';
            }
            else {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig?';
            }
        }

        else if(country == 'Belgium-NL'){
            if(activeStep == 0){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u soms hulp nodig?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij de informatie over uw bedrijf?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het melden van uw verbruik?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het vinden van de juiste aanbieding?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het instellen van uw passen?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij de informatie over uw bedrijf ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het instellen van uw passen?';
            }
            else if (activeStep == 3){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij het milieubeschermingsprogramma?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig bij de betalingsopties?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig?';
            }
            else {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', hebt u hulp nodig?';
            }
        }

        else if(country == 'Belgium-FR'){
            if(activeStep == 0){
                chatFirstMessage = 'Bonjour' + clientNameToChat + ', avez-vous besoin d\\\'aide ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour localiser votre entreprise ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour définir votre consommation de carburant ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour choisir l\\\'offre de crédit qui vous convient le mieux ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour configurer vos cartes ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour localiser votre entreprise ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour configurer vos cartes ?';
            }
            else if (activeStep == 3){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide en ce qui concerne le programme Eco-fee ?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide en ce qui concerne les options de paiement ?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide ?';
            }
            else {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide ?';
            }
        }

        else if(country == 'Russia'){
            chatFirstMessage = 'Добрый день' + clientNameToChat + ', чем мы можем Вам помочь?';
        }

        else if(country == 'Poland'){
            if(activeStep == 0){
                chatFirstMessage = 'Witaj' + clientNameToChat + ', wydaje się, że potrzebujesz pomocy';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy w znalezieniu swojej firmy?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy w określeniu zużycia paliwa?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy z wyborem oferty kredytowej odpowiedniej dla Ciebie?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy w konfiguracji kart?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy w znalezieniu swojej firmy?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy w konfiguracji kart?';
            }
            else if (activeStep == 3){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy z programem dopłaty ekologicznej lub Międzynarodowy program zwrotu podatku VAT?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy z opcjami płatności?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')){
                chatFirstMessage = 'Witaj' + clientNameToChat + '. Czy potrzebujesz pomocy?';
            }
            else {
                chatFirstMessage = 'Witaj' + clientNameToChat + '. wydaje się, że potrzebujesz pomocy';
            }
        }

        else if(country == 'Hungary'){
            if(activeStep == 0){
                chatFirstMessage = 'Üdvözöljük, úgy tűnik, Ön segítségre szorul.';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre cége megtalálásához?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre az üzemanyag fogyasztás meghatározásához?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre az Ön számára megfelelő hitelajánlat kiválasztásához?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre az üzemanyagkártyák konfigurálásához?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre vállalata megtalálásához?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre az üzemanyagkártyák konfigurálásához?';
            }
            else if (activeStep == 3){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre az öko-díj programra vonatkozóan?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre a fizetési módokat illetően?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')){
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + '. Szüksége van segítségre?';
            }
            else {
                chatFirstMessage = 'Üdvözöljük' + clientNameToChat + ', úgy tűnik, Ön segítségre szorul.';
            }
        }

        else if(country == 'France'){
            if(activeStep == 0){
                chatFirstMessage = 'Bonjour' + clientNameToChat + ', avez-vous besoin d\\\'aide ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour localiser votre entreprise ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour définir votre consommation de carburant ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour choisir l\\\'offre de crédit qui vous convient le mieux ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour configurer vos cartes ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour localiser votre entreprise ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour configurer vos cartes ?';
            }
            else if (activeStep == 3){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide en ce qui concerne le programme Eco-fee ?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide en ce qui concerne les options de paiement ?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')){
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide ?';
            }
            else {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide ?';
            }
        }

        else if (country == 'Austria') {
            if (activeStep == 0){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie vielleicht Hilfe?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe Ihr Unternehmen anzugeben?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung bei der Angabe Ihres Verbrauchs?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe das richtige Angebot zu finden?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei der Einrichtung Ihrer Karten?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe Ihr Unternehmen anzugeben?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei der Einrichtung Ihrer Karten?';
            }
            else if (activeStep == 3) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe beim Umweltschutz-Programm?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei den Zahlungsoptionen?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung?';
            }
            else {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung?';
            }
        }

        else if (country == 'Switzerland-DE') {
            if (activeStep == 0){
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie vielleicht Hilfe?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe Ihr Unternehmen anzugeben?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung bei der Angabe Ihres Verbrauchs?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe das richtige Angebot zu finden?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei der Einrichtung Ihrer Karten?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe Ihr Unternehmen anzugeben?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei der Einrichtung Ihrer Karten?';
            }
            else if (activeStep == 3) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe beim Umweltschutz-Programm?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Hilfe bei den Zahlungsoptionen?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')) {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung?';
            }
            else {
                chatFirstMessage = 'Hallo' + clientNameToChat + ', brauchen Sie Unterstützung?';
            }
        }

        else if (country == 'Switzerland-FR') {
            if (activeStep == 0) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + ', avez-vous besoin d\\\'aide ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Search company')) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour localiser votre entreprise ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Set total consumption')) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour définir votre consommation de carburant ?';
            }
            else if ((activeStep == 1) && (activeSubStep == 'Calculating credit score')) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour choisir l\\\'offre de crédit qui vous convient le mieux ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Card configuration')) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour configurer vos cartes ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Choosing offer')) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour localiser votre entreprise ?';
            }
            else if ((activeStep == 2) && (activeSubStep == 'Technical parameters')) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide pour configurer vos cartes ?';
            }
            else if (activeStep == 3) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide en ce qui concerne le programme Eco-fee ?';
            }
            else if ( (activeStep == 4) &&
                    ((activeSubStep == 'DirectDebit') || (activeSubStep == 'DirectDebitDeposit') ||
                            (activeSubStep == 'BankTransfer') || (activeSubStep == 'BankTransferDeposit')) ) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide en ce qui concerne les options de paiement ?';
            }
            else if ((activeStep == 5) && (activeSubStep == 'Congratulations')) {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide ?';
            }
            else {
                chatFirstMessage = 'Bonjour' + clientNameToChat + '. Avez-vous besoin d\\\'aide ?';
            }
        }

        else {
            chatFirstMessage = 'Hi' + clientNameToChat + ', do you need any help?';
        }
        return chatFirstMessage;
    }

    /*******************************************************************************
    *  Name            : saveOfflineChatLog
    *  Summary         : save LiveChatVisitor and LiveChatTranscript records for OFFLINE chat
    *  CreatedDate     : 18.04.2018
    *  ModifiedDate    : -
    *  Parameters      : String textBody, String clientIpAddress
    *  Returns         : -
    ******************************************************************************/
    public static void saveOfflineChatLog(String textBody, String clientIpAddress, Integer activeStep, String activeSubStep, String countryName, String oppId, String conId){
        if (oppId != null && oppId != '' || conId != null && conId != '') {
            LiveChatTranscript clientCurrentChat;
            for (LiveChatTranscript clientChat : [
                    SELECT Id, AccountId, Opportunity__c, ContactId, Body, StartTime, RequestTime,
                            LiveChatVisitorId, OwnerId, E2E_Step__c, Type__c, Mode_of_initialization__c, Country__c,
                            VisitorMessageCount, OperatorMessageCount
                    FROM LiveChatTranscript
                    WHERE Opportunity__c = :oppId AND
                    Type__c = 'offline'
            ]) {
                if (clientChat.StartTime.date() == system.today() && textBody.stripHtmlTags().contains(clientChat.Body.stripHtmlTags())) {
                    clientCurrentChat = clientChat;
                }
            }

            if (clientCurrentChat != null) {
                clientCurrentChat.Body = textBody;
                clientCurrentChat.VisitorMessageCount += 1;
                clientCurrentChat.E2E_Step__c = activeSubStep;
                update clientCurrentChat;
            } else {
                LiveChatVisitor newVisitor = new LiveChatVisitor();
                insert newVisitor;

                clientCurrentChat = new LiveChatTranscript();
                List<Group> queueOffline = [
                        SELECT id, Name
                        FROM Group
                        WHERE Name = :offlineChatQueues.get(countryName)
                        LIMIT 1
                ];
                if (queueOffline.size() == 1) {
                    clientCurrentChat.OwnerId = queueOffline.get(0).id;
                }
                clientCurrentChat.LiveChatVisitorId = newVisitor.id;
                clientCurrentChat.RequestTime = system.now();
                clientCurrentChat.StartTime = system.now();
                clientCurrentChat.E2E_Step__c = activeSubStep;
                clientCurrentChat.Type__c = 'offline';
                clientCurrentChat.Mode_of_initialization__c = 'manual';
                clientCurrentChat.Body = textBody;
                if (oppId != null && oppId != '') {
                    clientCurrentChat.Opportunity__c = oppId;
                }
                if (conId != null && conId != '') {
                    clientCurrentChat.ContactId = conId;
                }
                if (countryName != null) clientCurrentChat.Country__c = countryName;
                clientCurrentChat.VisitorMessageCount = 0;
                clientCurrentChat.OperatorMessageCount = 0;
                insert clientCurrentChat;
            }
        }
    }

    /*******************************************************************************
    *  Name            : setFlagChatToOpportunity
    *  Summary         : set flag that chat is using
    *  CreatedDate     : 18.04.2018
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId, String modeOfChat, Integer activeStep, String activeSubStep
    *  Returns         : -
    ******************************************************************************/
    public static void setFlagChatToOpportunity(String opportunityId, String modeOfChat, Integer activeStep, String activeSubStep){
        if ((modeOfChat != '') && (opportunityId != null)){
            List<Opportunity> currentOpportunity = [SELECT id, E2E_Chat__c, E2E_Chat_Step__c FROM Opportunity WHERE id = :opportunityId];
            if (currentOpportunity.size() != 0){
                if(currentOpportunity.get(0).E2E_Chat_Step__c == null || currentOpportunity.get(0).E2E_Chat_Step__c == ''){
                    system.debug(modeOfChat);
                    if (modeOfChat == 'manual'){
                        currentOpportunity.get(0).E2E_Chat__c ='initiated manual';
                    }
                    else if (modeOfChat == 'automatical'){
                        currentOpportunity.get(0).E2E_Chat__c ='initiated auto';
                    }
                    currentOpportunity.get(0).E2E_Chat_Step__c = activeSubStep;
                    system.debug( currentOpportunity.get(0).E2E_Chat__c);
                    update currentOpportunity;
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : Map<String, LongFormPage> getPagesMap()
    *  Summary         : return all pages for Chat
    *  CreatedDate     : 18.04.2018
    *  ModifiedDate    : 03.06.2019
    *  Parameters      : -
    *  Returns         : Map<String, LongFormPage> pagesMap
    ******************************************************************************/
    public Map<String, LongFormPage> getPagesMap() {
        return pageMapChat;
    }

    public static Map<String, String> offlineChatQueues = new Map<String, String>{
        'Germany' => 'e2eOfflineChatDE',
        'Netherlands' => 'e2eOfflineChatNL',
        'Belgium-NL' => 'e2eOfflineChatBENL',
        'Belgium-FR' => 'e2eOfflineChatBEFR',
        'Russia' => 'e2eOfflineChatRU',
        'France' => 'e2eOfflineChatFR',
        'Poland' => 'e2eOfflineChatPL',
        'Hungary' => 'e2eOfflineChatHU',
        'Austria' => 'e2eOfflineChatAT',
        'Switzerland-DE' => 'e2eOfflineChatCHDE',
        'Switzerland-FR' => 'e2eOfflineChatCHFR'
    };


    //All methods above need to be remove from this class (no need more)
    public void setOpportunity(Opportunity opp) {}

    public void setContact(Contact con) {}

    public void setOpportunity(Id opportunityId) {}

    public void setContact(Id contactId) {}
}