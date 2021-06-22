/**
 * Created by Aleksandr.Gaakh on 19.03.2021.
 */

public with sharing class RegionApiParser {
    public static String getDomString(HttpResponse response, String parentElement) {
        response.setBody(response.getBody().substringBetween('soap+xml"', '--uuid'));
        Dom.Document doc = response.getBodyDocument();
        Dom.XmlNode envelope = doc.getRootElement();

        for (Dom.XmlNode body : envelope.getChildElements()) {
            if (body.getName() == 'Body') {
                for (Dom.XmlNode loginResponse : body.getChildElements()) {
                    if (loginResponse.getName() == parentElement) {
                        for (Dom.XmlNode root : loginResponse.getChildElements()) {
                            return root.getText();
                        }
                    }
                }
            }
        }

        return null;
    }

    public static Dom.XmlNode getCompanyFullReportDomElement(HttpResponse response, String parentElement, String childElement) {
        response.setBody(response.getBody().substringBetween('soap+xml"', '--uuid'));
        Dom.Document doc = response.getBodyDocument();
        Dom.XmlNode envelope = doc.getRootElement();

        for (Dom.XmlNode body : envelope.getChildElements()) {
            if (body.getName() == 'Body') {
                for (Dom.XmlNode loginResponse : body.getChildElements()) {
                    if (loginResponse.getName() == parentElement) {
                        for (Dom.XmlNode root : loginResponse.getChildElements()) {
                            if (root.getName() == childElement) {
                                Dom.Document domDoc = new Dom.Document();
                                domDoc.load(root.getText());
                                Dom.XmlNode rootDom = domDoc.getRootElement();
                                for (Dom.XmlNode companyInfoElement : rootDom.getChildElements()) {
                                    if (companyInfoElement.getName() == 'dane') {
                                        return companyInfoElement;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static Dom.XmlNode getCompaniesDomElement(HttpResponse response, String parentElement, String childElement) {
        response.setBody(response.getBody().substringBetween('soap+xml"', '--uuid'));
        Dom.Document doc = response.getBodyDocument();
        Dom.XmlNode envelope = doc.getRootElement();

        for (Dom.XmlNode body : envelope.getChildElements()) {
            if (body.getName() == 'Body') {
                for (Dom.XmlNode loginResponse : body.getChildElements()) {
                    if (loginResponse.getName() == parentElement) {
                        for (Dom.XmlNode root : loginResponse.getChildElements()) {
                            if (root.getName() == childElement) {
                                Dom.Document domDoc = new Dom.Document();
                                domDoc.load(root.getText());
                                Dom.XmlNode rootDom = domDoc.getRootElement();
                                return rootDom;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String getErrorMessage(Dom.XmlNode xmlDom){
        String errorMessage = '';
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()){
            if (companyInfoElement.getName() == 'ErrorCode') {
                errorMessage += companyInfoElement.getName() + ': ' + companyInfoElement.getText() + '. ';
            } else if (companyInfoElement.getName() == 'ErrorMessageEn') {
                errorMessage += companyInfoElement.getText() + ' ';
            } else if (companyInfoElement.getName() == 'pRegon') {
                errorMessage += 'Region number - ' + companyInfoElement.getText();
            } else if (companyInfoElement.getName() == 'Nipy') {
                errorMessage += 'TaxId - ' + companyInfoElement.getText();
            }
        }

        return errorMessage;
    }

    public static String getName(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_nazwa' || companyInfoElement.getName() == 'fiz_nazwa') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getStreet(Dom.XmlNode xmlDom) {
        String street = '';
        String propertyNr = '';
        String aptNr = '';
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_adSiedzUlica_Nazwa' || companyInfoElement.getName() == 'fiz_adSiedzUlica_Nazwa') {
                street = companyInfoElement.getText();
            }
            if (companyInfoElement.getName() == 'praw_adSiedzNumerNieruchomosci' || companyInfoElement.getName() == 'fiz_adSiedzNumerNieruchomosci') {
                propertyNr = companyInfoElement.getText();
            }
            if ((companyInfoElement.getName() == 'praw_adSiedzNumerLokalu' || companyInfoElement.getName() == 'fiz_adSiedzNumerLokalu') && !String.isBlank(propertyNr)) {
                aptNr = companyInfoElement.getText();
            }
        }
        return street + ' ' + (!String.isBlank(street) ? propertyNr : '') + ' ' + aptNr;
    }

    public static String getCity(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_adSiedzMiejscowosc_Nazwa' || companyInfoElement.getName() == 'fiz_adSiedzMiejscowosc_Nazwa') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getState(Dom.XmlNode xmlDom){
        Map<String, String> states = new Map<String, String>{
                'dolnośląskie' => 'Lower Silesia',
                'kujawsko-pomorskie' => 'Kuyavia-Pomerania',
                'lubuskie' => 'Lubusz',
                'łódzkie' => 'Łódź',
                'lubelskie' => 'Lublin',
                'małopolskie' => 'Lesser Poland',
                'mazowieckie' => 'Mazovia',
                'opolskie' => 'Opole',
                'podlaskie' => 'Podlaskie',
                'podkarpackie' => 'Subcarpathia',
                'pomorskie' => 'Pomerania',
                'świętokrzyskie' => 'Holy Cross',
                'śląskie' => 'Silesia',
                'warmińsko-mazurskie' => 'Warmia-Masuria',
                'wielkopolskie' => 'Greater Poland',
                'zachodniopomorskie' => 'West Pomerania'
        };
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_adSiedzWojewodztwo_Nazwa' || companyInfoElement.getName() == 'fiz_adSiedzWojewodztwo_Nazwa') {
                return states.get(companyInfoElement.getText().toLowerCase());
            }
        }
        return null;
    }

    public static String getPostalCode(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_adSiedzKodPocztowy' || companyInfoElement.getName() == 'fiz_adSiedzKodPocztowy') {
                if (companyInfoElement.getText() != null && companyInfoElement.getText() != '') {
                    return companyInfoElement.getText().substring(0, 2) + '-' + companyInfoElement.getText().substring(2, 5);
                }
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getTaxId(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_nip' || companyInfoElement.getName() == 'fiz_nip' || companyInfoElement.getName() == 'Nip') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getTradeRegisterNr(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_regon9' || companyInfoElement.getName() == 'fiz_regon9') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getYearOfFoundation(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_dataPowstania' || companyInfoElement.getName() == 'fiz_dataPowstania') {
                if (!String.isBlank(companyInfoElement.getText())) {
                    return companyInfoElement.getText().substring(0, 4);
                }
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getDateOfFoundation(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_dataPowstania' || companyInfoElement.getName() == 'fiz_dataPowstania') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getPhone(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_numerTelefonu' || companyInfoElement.getName() == 'fiz_numerTelefonu') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getEmail(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_adresEmail' || companyInfoElement.getName() == 'fiz_adresEmail') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getWebsite(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_adresStronyinternetowej' || companyInfoElement.getName() == 'fiz_adresStronyinternetowej') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getSuspendingActivityDate(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_dataZawieszeniaDzialalnosci' || companyInfoElement.getName() == 'fiz_dataZawieszeniaDzialalnosci') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getResumingActivityDate(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'praw_dataWznowieniaDzialalnosci' || companyInfoElement.getName() == 'fiz_dataWznowieniaDzialalnosci') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

//    public static String getPKD(Dom.XmlNode xmlDom) {
//        String nace = '';
//        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
//            if (companyInfoElement.getName() == 'praw_pkdKod' || companyInfoElement.getName() == 'fiz_pkd_Kod') {
//                nace += companyInfoElement.getText();
//            }
//            if (companyInfoElement.getName() == 'praw_pkdNazwa' || companyInfoElement.getName() == 'fiz_pkd_Nazwa') {
//                nace += ' ' + companyInfoElement.getText().toLowerCase().capitalize();
//            }
//        }
//        return nace;
//    }
//
//    public static String getPKDStatus(Dom.XmlNode xmlDom) {
//        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
//            if (companyInfoElement.getName() == 'praw_pkdPrzewazajace' || companyInfoElement.getName() == 'fiz_pkd_Przewazajace') {
//               return companyInfoElement.getText();
//            }
//        }
//        return null;
//    }

//    public static String getLegalForm(Dom.XmlNode xmlDom) {
//        Map<String, String> legalForms = new Map<String, String>{
//                'jednoosobowa działalność gospodarcza' => 'Sole proprietorship', // To create new picklist value
//                'SPÓŁKI CYWILNE PROWADZĄCE DZIAŁALNOŚĆ W OPARCIU O UMOWĘ ZAWARTĄ NA PODSTAWIE KODEKSU CYWILNEGO' => 'Civil law partnership',
//                'SPÓŁKI Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ' => 'The Polish Limited Liability Company (sp.z o.o)',
//                'SPÓŁKI AKCYJNE' => 'The Polish Joint Stock Company (S.A.)',
//                'SPÓŁKI JAWNE' => 'General or Registered Partnership (sp. j.)',
//                'SPÓŁKI PARTNERSKIE' => 'Limited Liability Partnership (sp. p.)',
//                'SPÓŁKI KOMANDYTOWE' => 'Limited Partnership (sp. k.)',
//                'SPÓŁKI KOMANDYTOWO - AKCYJNE' => 'Limited Joint Stock Partnership (S.K.A.)',
//                'FUNDACJE' => 'Foundation'
//        };
//        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
//            if (companyInfoElement.getName() == 'praw_szczegolnaFormaPrawna_Nazwa' || companyInfoElement.getName() == 'fiz_szczegolnaFormaPrawna_Nazwa') {
//                if (legalForms.containsKey(companyInfoElement.getText().toUpperCase())) {
//                    return legalForms.get(companyInfoElement.getText().toUpperCase());
//                } else {
//                    return 'Other';
//                }
//            }
//        }
//        return null;
//    }

    public static String getType(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'Typ') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getSilosId(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'SilosID') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

    public static String getRegionId(Dom.XmlNode xmlDom) {
        for (Dom.XmlNode companyInfoElement : xmlDom.getChildElements()) {
            if (companyInfoElement.getName() == 'Regon') {
                return companyInfoElement.getText();
            }
        }
        return null;
    }

}
