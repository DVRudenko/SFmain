@isTest
public with sharing class PPR_API_DataTestFactory {

    public static LongForm_Offer__c createOffer() {
        LongForm_Offer__c offer = new LongForm_Offer__c(
                Country__c = 'Russia',
                Product__c = 'PetrolPlus'
        );

        return offer;
    }
    
    public static LongForm_Fleetcor_Product__c createProductOffer(Id offerId) {
        LongForm_Fleetcor_Product__c productOffer = new LongForm_Fleetcor_Product__c(
                Name = 'PetrolPlus_Rover',
                Active__c = true,
                Long_Form_Offer__c = offerId,
                Label__c = 'Вездеход Online'
        );

        return productOffer;
    }

    public static LongForm_Tariff__c createLongFormTariff() {
        LongForm_Tariff__c tariffProduct = new LongForm_Tariff__c(
            Name = '1OPTIMAL_CONTRACT',
            Label__c = 'Оптимальный'
        );

        return tariffProduct;
    }

    public static PPR_API_Settings__c createPPR_API_Settings() {
        return new PPR_API_Settings__c(
            Name = 'europlan',
            Block_API_Actions__c = false,
            Callback_URI__c = 'https://webhook.site/8e0cfe31-db8a-4447-905d-7be72f7749a3',
            Contract_Type__c = 14,
            Due_date__c = 3,
            Credit_days_ppr__c = 'к14д',
            Prepay_sum__c = '100'
        );
    }

    public static E2E_Promocodes__c createPromocode(String name, String additionalField, String reportIdentifiers) {
        return new E2E_Promocodes__c(
            Name = name,
            Promocode_Additional_Field__c = additionalField,
            Report_Identifiers__c = reportIdentifiers,
            Apply_to_tariffs__c = '1OPTIMAL_CARDS;1OPTIMAL_CONTRACT;2CHOOSEN_CARDS;2CHOOSEN_CONTRACT;1CARDS_CARDS;2CONTRACT_CARDS;',
            Enable_Main_Promo__c = true,
            Product_Name__c = 'Вездеход Online',
            Promocode_Label__c = 'Отмена ИУ на 3М + цена стелы ГПН+ГЭС на 3М'
        );
    }

    public static Custom_log__c createCustomLog(Id formDataId, String inn) {
        return new Custom_log__c(
                E2E_Form_Ru_Data__c = formDataId,
                External_user__c = 'Dobrynia Nikitich',
                INN__c = inn,
                Source__c = 'europlan'
        );
    }

    public static DadataBank setDadataBankInfo() {
        DadataBank dataBank = new DadataBank();
        dataBank.name = '';
        dataBank.nameShort = '';
        dataBank.bic = '';
        dataBank.correspondentAccount = '';
        dataBank.okpo = '';
        dataBank.town = '';
        dataBank.address = '';

        return dataBank;
    }

    public static List<Map<String, Object>> setCardsData() {
        return new List<Map<String, Object>> {
            new Map<String, Object> {
                'id' => '1337f71a-81b2-11ea-a527-6bba62241005',
                'number' => '4000100001',
                'is_active'  => true,
                'is_issued' => false,
                'CardPartners' => new List<Object> {
                    new Map<String, Object> {
                        'partner_id' => '1337f71a-81b2-11ea-a527-6bba62248004',
                        'id' => '3dbb3658-8214-11ea-8e0c-f35a8f317e5a',
                        'card_id' => '1337f71a-81b2-11ea-a527-6bba62241005',
                        'Partner' => new Map<String, Object> {
                                'name' => 'Европлан',
                                'alias' => 'europlan',
                                'id' => '1337f71a-81b2-11ea-a527-6bba62248004'
                        }
                    }
                }
            }, new Map<String, Object> {
                'id' => '1337f71a-81b2-11ea-a527-6bba62241002',
                'number' => '3005553535',
                'is_active'  => true,
                'is_issued' => false,
                'CardPartners' => new List<Object> {
                        new Map<String, Object> {
                                'partner_id' => '1337f71a-81b2-11ea-a527-6bba62248004',
                                'id' => '1337f71a-81b2-11ea-a527-6bba62241006',
                                'card_id' => '1337f71a-81b2-11ea-a527-6bba62241002',
                                'Partner' => new Map<String, Object> {
                                        'name' => 'Европлан',
                                        'alias' => 'europlan',
                                        'id' => '1337f71a-81b2-11ea-a527-6bba62248004'
                                }
                        }
                }
            }
        };
    }

    public static Map<String, Object> generateTestRequest(String formDataId, String inn) {
        String testId = (formDataId == null) ? 'a5H0O000000TRY6' : formDataId;

        return new Map<String, Object> {
            'metadata' => new Map<String, Object> {
                'source' => 'europlan',
                'id' => testId,
                'user' => 'Dobrynia Nikitich'
            },
            'customerInfo' => new Map<String, Object> {
                'legalInfo' => new Map<String, Object> {
                    'inn' => inn,
                    'codeWord' => 'кодовоеслово',
                    'emails' => new List<Object> {
                        new Map<String, Object> {
                            'value' => 'ya@krevedko.ru',
                            'type' => new List<Object> {
                                'Web portal',
                                'Documents',
                                'Reports',
                                'Reports(TCI)',
                                'Invoices',
                                'Mail',
                                'First PIN delivery',
                                'LK accesses'
                            }
                        }
                    },
                    'phones' => new List<Object> {
                        new Map<String, Object> {
                            'value' => new Map<String, Object> {
                                'code' => '7',
                                'numberStr' => '8002553535',
                                'ext' => '-'
                            },
                            'type' => new List<Object> {
                                'Financial Notification',
                                'Advertisement',
                                'Private',
                                'Mobile',
                                'Main',
                                'Pin recovery',
                                'SMS Notifications',
                                'Print on post envelope'
                            }
                        }
                    },
                    'agreements' => new List<Object> {
                        'PersonalData',
                        'MarketingProgram'
                    }
                },
                'additionalInfo' => new Map<String, Object>{ 
                    'courierServiceComments' => 'для идентификации сказать пароль: пароль'
                },
                'orderInfo' => new Map<String, Object> {
                    'product' => 'PetrolPlus_Rover',
                    'tariff' => '2CHOOSEN_cards',
                    'orderType' => 'Overdraft',
                    'overdraftSum' => '100000',
                    'services' => new List<Object> {
                        'PersonalManager',
                        'ExpressDocDelivery'
                    },
                    'promos' => new List<Object> {
                        '9E15',
                        '9E25'
                    },
                    'cards' => new List<Object> {
                        '4000100001',
                        '3005553535'
                    }
                },
                'bankInfo' => new Map<String, Object> {
                    'bik' => '044030843',
                    'accountNum' => '40817810099910004312'
                },
                'addresses' => new List<Object> {
                    new Map<String, Object> {
                        'countryCode' => '643',
                        'addressId' => '5ee84ac0-eb9a-4b42-b814-2f5f7c27c255',
                        'zipCode' => '644119',
                        'country' => 'Russia',
                        'state' => 'Областная обл.',
                        'city' => 'г. Грёз',
                        'street' => 'ул. Пушкина',
                        'house' => 'дом Колотушкина',
                        'apartment' => 'офис 404',
                        'type' => new List<Object> {
                            'Billing'
                        }
                    },
                    new Map<String, Object> {
                        'countryCode' => '643',
                        'addressId' => '5ee84ac0-eb9a-4b42-b814-2f5f7c27c255',
                        'zipCode' => '644119',
                        'country' => 'Russia',
                        'state' => 'Областная обл.',
                        'city' => 'г. Грёз',
                        'street' => 'ул. Пушкина',
                        'house' => 'дом Колотушкина',
                        'apartment' => 'офис 404',
                        'type' => new List<Object> {
                            'Shipping'
                        }
                    }
                },
                'staff' => new List<Object> {
                    new Map<String, Object> {
                        'firstName' => 'Василий',
                        'lastName' => 'Пупкин',
                        'Surname' => 'Васильевич',
                        'email' => 'vasily.pupkin@emal.ru',
                        'role' => 'Decision Maker',
                        'position' => 'генеральный директор',
                        'phones' => new List<Object> {
                            new Map<String, Object> {
                                'value' => new Map<String, Object> {
                                    'code' => '7',
                                    'numberStr' => '8002553535',
                                    'ext' => '-'
                                },
                                'type' => new List<Object> {
                                    'phone',
                                    'Mobile',
                                    'Additional phone'
                                }
                            }
                        }
                    }
                }
            }
        };
    }

    public static Map<String, Object> generateTestRequestMandatoryFields(String formDataId, String inn) {
        String testId = (formDataId == null) ? 'a5H0O000000TRY6' : formDataId;

        return new Map<String, Object> {
            'metadata' => new Map<String, Object> {
                'source' => 'europlan',
                'id' => testId
            },
            'customerInfo' => new Map<String, Object> {
                'legalInfo' => new Map<String, Object> {
                    'inn' => inn,
                    'codeWord' => 'кодовоеслово',
                    'emails' => new List<Object> {
                        new Map<String, Object> {
                            'value' => 'ya@krevedko.ru',
                            'type' => new List<Object> {
                                'Web portal',
                                'Documents',
                                'Reports',
                                'Reports(TCI)',
                                'Invoices',
                                'Mail',
                                'First PIN delivery',
                                'LK accesses'
                            }
                        }
                    },
                    'phones' => new List<Object> {
                        new Map<String, Object> {
                            'value' => new Map<String, Object> {
                                'code' => '7',
                                'numberStr' => '8002553535',
                                'ext' => '-'
                            },
                            'type' => new List<Object> {
                                'Financial Notification',
                                'Advertisement',
                                'Private',
                                'Mobile',
                                'Main',
                                'Pin recovery',
                                'SMS Notifications',
                                'Print on post envelope'
                            }
                        }
                    },
                    'agreements' => new List<Object> {
                        'PersonalData',
                        'MarketingProgram'
                    }
                },
                'orderInfo' => new Map<String, Object> {
                    'overdraftSum' => '100000',
                    'cards' => new List<Object> {
                        '4000100001'
                    },
                    'promos' => new List<Object> {
                        '9E15',
                        '9E25'
                    }
                },
                'bankInfo' => new Map<String, Object> {
                    'bik' => '044030843',
                    'accountNum' => '40817810099910004312'
                }
            }
        };
    }
}