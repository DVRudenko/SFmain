public class ETELongFormJITBController {

    public Map<String,String> content {get; set;}

    public ETELongFormJITBController() {}

    public void init() {
        String country_code = ApexPages.currentPage().getHeaders().get('Host').substringAfterLast('.');
        country_code = country_code == 'com' ? 'de' : country_code;
        this.content = this.translationsAndSettings().get(country_code);
    }

    private Map<String,Map<String,String>> translationsAndSettings(){
        return new Map<String,Map<String,String>>{
            'de' => new Map<String,String>{
                'title' => 'Shell Tankkarten online bestellen',
                'headerTitle' => 'Kunde werden und Tankkarten beantragen',
                'cardTitle' => 'Sehr geehrter Kunde, bitte teilen Sie uns mit, an welcher Shell-Station Sie unsere Werbematerialien gesehen haben.',
                'addressTitle' => 'Stammtankstelle:',
                'buttonTitle' => 'Auswählen',
                'waitingForRedirection' => 'Weiterleitung zum Bestellformular',
                'popupBlocked' => 'Wenn Sie nicht weitergeleitet wurden, drücken Sie bitte die Taste unten',
                'buttonTitleGoToForm' => 'BESTELLFORMULAR',
                'footerDescription' => 'FLEETCOR ist ein führender, unabhängiger, globaler Anbieter von spezialisierten Zahlungsprodukten und -dienstleistungen, wie Flottenkarten, Essenskarten, Rabattkarten für Geschäftshotels und andere spezielle Zahlungsservices für Unternehmen auf der ganzen Welt.',
                'frameLink' => 'https://eurolocator.fleetcor.de/?product=4&lang=de&mode=choose-station&address=Germany&zoom=7&locationRequest=1',
                'footerCopyRight' => 'FLEETCOR 2019 Urheberrecht und Haftungsausschluss.',
                'footerCopyRightLink' => 'https://fleetcor.de/urheberrecht-und-haftungsausschluss',
                'longFormLink' => '/etede',
                'countryCode' => 'de',
                'country' => 'Germany',
                'recordType' => 'Germany'
            },
            'pl' => new Map<String,String>{
                'title' => 'Shell Tankkarten online bestellen',
                'headerTitle' => 'Zamawiaj karty paliwowe Shell online',
                'cardTitle' => 'Szanowny Kliencie, proszę daj nam znać, na której stancji paliw Shell widziałeś nasze materiały promocyjne.',
                'addressTitle' => 'Wybrana stacja:',
                'buttonTitle' => 'Wybierz',
                'waitingForRedirection' => 'Przekierowanie do formularza zamówienia',
                'popupBlocked' => 'Jeśli nie zostałeś przekierowany, proszę kliknąć na przycisk poniżej',
                'buttonTitleGoToForm' => 'FORMULARZ ZAMÓWIENIA',
                'footerDescription' => 'FLEETCOR to wiodący globalny dostawca specjalistycznych produktów i usług płatniczych, włącznie z kartami flotowymi, kartami restauracyjnymi, zniżkowymi kartami na noclegi służbowe, oraz innych specjalistycznych usług płatniczych dla firm na całym świecie.',
                'frameLink' => 'https://eurolocator.fleetcor.pl/?product=4&lang=pl&mode=choose-station&address=Polska&zoom=7&locationRequest=1',
                'footerCopyRight' => 'FLEETCOR 2019. Wszelkie prawa zastrzeżone.',
                'footerCopyRightLink' => 'https://fleetcor.pl/prawa-autorskie-i-nota-prawna',
                'longFormLink' => '/etepl',
                'countryCode' => 'pl',
                'country' => 'Poland',
                'recordType' => 'Poland'
            },
            'en' =>new Map<String,String>{
                'waitingForRedirection' => 'Redirecting to the order form..',
                'popupBlocked' => 'If you were not redirected, please press the button below',
                'buttonTitleGoToForm' => 'ORDER FORM'
            }
        };
    }
}