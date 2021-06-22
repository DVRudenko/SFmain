@isTest
public with sharing class DirectumDataTestFactory {

    public static Map<String, Object> generateContractTestRequest() {
        return new Map<String, Object>{
                'metadata' => new Map<String, Object>{
                        'transactionId' => '7d5fd1bf-8ea1-406a-9da3-a8c71a9088e7',
                        'user' => 'Test User',
                        'TSCreated' => '1604516956',
                        'TSSent' => '1605208156',
                        'source' => 'directum'
                },
                'Data' => new Map<String, Object>{
                        'contractStage' => 'contract agreed',
                        'contractDate' => '2020-11-20',
                        'externalId' => '0061q00000A54uD',
                        'contractId' => '1169bda2-d828-408e-a4ab-eb30798a9216',
                        'contractNumber' => '4-6907',
                        'contractLink' => 'SRV-DMS-APP.transitcard.ru/drxweb/Contract/1169bda2-d828-408e-a4ab-eb30798a9216',
                        'message' => ''
                }
        };
    }
}