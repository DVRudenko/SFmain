@RestResource(urlMapping='/PaymentResult')
global class E2EPaymentConfirmation {

    /*******************************************************************************
    *  Name            : getPaymentInformation
    *  Summary         : Get information about confirmation transaction from Ingenico
    *  CreatedDate     : 28.02.2018
    *  ModifiedDate    : 28.02.2018
    *  Parameters      : --
    *  Returns         : ---
    ******************************************************************************/
    @HttpGet
    global static void getPaymentInformation() {
        try {
            String acceptance = RestContext.request.params.get('ACCEPTANCE');       // Acceptance code returned by acquirer
            String amount = RestContext.request.params.get('amount');               // Order amount (not multiplied by 100)
            String brand = RestContext.request.params.get('BRAND');                 // Card brand or similar information for other payment methods
            String cardno = RestContext.request.params.get('CARDNO');               // Card number or account number
            String CN = RestContext.request.params.get('CN');                       // Card holder (customer) name
            String currencyValue = RestContext.request.params.get('currency');      // Order currency
            String ED = RestContext.request.params.get('ED');                       // Expiry date
            String NCERROR = RestContext.request.params.get('NCERROR');             // Error code
            String orderID = RestContext.request.params.get('orderID');             // Your order reference
            String payID = RestContext.request.params.get('PAYID');                 // Payment reference in our(Ingenico) system
            String paymentMethod = RestContext.request.params.get('PM');            // Payment method
            String sco_category = RestContext.request.params.get('SCO_CATEGORY');   // Scoring categories. Possible values: G (green), O (orange), R (red).
            String scoring = RestContext.request.params.get('SCORING');             // Final score of a transaction.
            String SHASIGN = RestContext.request.params.get('SHASIGN');             // SHA signature calculated by our system (if SHA-OUT configured)
            String status = RestContext.request.params.get('STATUS');               // Transaction status
            String TRXDATE = RestContext.request.params.get('TRXDATE');             // Transaction date

            Decimal amount_Decimal = Decimal.valueOf(amount);
            List<Payment_Transaction__c> targetTransaction = [
                    SELECT ID, ACCEPTANCE__c, Currency__c, Amount__c, BRAND__c, NCERROR__c,
                            orderID__c, PAYID__c, PaymentMethod__c, TRXDATE__c, status__c, OpportunityId__c
                    FROM Payment_Transaction__c
                    WHERE orderID__c = :orderID
                    AND Currency__c = :currencyValue
                    AND Amount__c = :Amount_Decimal
                    AND Authorized__c = FALSE
                    LIMIT 1
            ];

            if ( !targetTransaction.isEmpty() ) {

                String e2eFormCustomSettingName = getCustomSettingName(targetTransaction.get(0).OpportunityId__c);

                String textToHash = '';
                String calculatedHash = '';
                if (E2EKeysAPI__c.getValues(e2eFormCustomSettingName) != null) {
                    String SHAsecretKeyOut = E2EKeysAPI__c.getValues(e2eFormCustomSettingName).SHA_KeyOut__c;

                    if ((acceptance <> null) && (acceptance <> '')) textToHash += 'ACCEPTANCE=' + acceptance + SHAsecretKeyOut;
                    if ((amount <> null) && (amount <> '')) textToHash += 'AMOUNT=' + amount + SHAsecretKeyOut;
                    if ((brand <> null) && (brand <> '')) textToHash += 'BRAND=' + brand + SHAsecretKeyOut;
                    if ((cardno  <> null) && (cardno <> '')) textToHash += 'CARDNO=' + cardno + SHAsecretKeyOut;
                    if ((CN <> null) && (CN <> '')) textToHash += 'CN=' + CN + SHAsecretKeyOut;
                    if ((currencyValue <> null) && (currencyValue <> '')) textToHash += 'CURRENCY=' + currencyValue + SHAsecretKeyOut;
                    if ((ED <> null) && (ED <> '')) textToHash += 'ED=' + ED + SHAsecretKeyOut;
                    if ((NCERROR <> null) && (NCERROR <> '')) textToHash += 'NCERROR=' + NCERROR + SHAsecretKeyOut;
                    if ((orderID <> null) && (orderID <> '')) textToHash += 'ORDERID=' + orderID + SHAsecretKeyOut;
                    if ((payID <> null) && (payID <> '')) textToHash += 'PAYID=' + payID + SHAsecretKeyOut;
                    if ((paymentMethod <> null) && (paymentMethod <> '')) textToHash += 'PM=' + paymentMethod + SHAsecretKeyOut;
                    if ((sco_category <> null) && (sco_category <> '')) textToHash += 'SCO_CATEGORY=' + sco_category + SHAsecretKeyOut;
                    if ((scoring <> null) && (scoring <> '')) textToHash += 'SCORING=' + scoring + SHAsecretKeyOut;
                    if ((status  <> null) && (status <> '')) textToHash += 'STATUS=' + status + SHAsecretKeyOut;
                    if ((TRXDATE <> null) && (TRXDATE <> '')) textToHash += 'TRXDATE=' + TRXDATE + SHAsecretKeyOut;

                    calculatedHash = E2EFormEncryption.getHashAlgorithmStringSHA1(textToHash).toUpperCase();
                }

                targetTransaction.get(0).ACCEPTANCE__c = acceptance;
                targetTransaction.get(0).Brand__c = brand;
                targetTransaction.get(0).Cardno__c = cardno;
                targetTransaction.get(0).CN__c = cn;
                targetTransaction.get(0).ED__C = ed;
                targetTransaction.get(0).NCERROR__c = NCERROR;
                targetTransaction.get(0).PayId__c = payID;
                targetTransaction.get(0).PaymentMethod__c = paymentMethod;
                targetTransaction.get(0).SCO_CATEGORY__c = sco_category;
                targetTransaction.get(0).SCORING__c = scoring;
                targetTransaction.get(0).TRXDate__c = TRXDATE;
                targetTransaction.get(0).status__c = status;
                targetTransaction.get(0).Description__c = 'SHASIGN = ' + SHASIGN + ' ||| ' + 'ACCEPTANCE = ' + acceptance + ' ||| ' + 'amount = ' + amount + ' ||| ' +
                        'BRAND = ' + brand + ' ||| ' + 'CARDNO = ' + cardno + ' ||| ' + 'CN = ' + CN + ' ||| ' + 'currency = ' + currencyValue + ' ||| ' +
                        'ED = ' + ED + ' ||| ' + 'NCERROR = ' + NCERROR + ' ||| ' + 'orderID = ' + orderID + ' ||| ' + 'PAYID = ' + payID + ' ||| ' +
                        'PM = ' + paymentMethod + ' ||| ' +
                        'SCO_CATEGORY = ' + sco_category + ' ||| ' + 'SCORING = ' + scoring + ' ||| ' +
                        'STATUS = ' + status + ' ||| ' + 'TRXDATE = ' + TRXDATE +' ||| '+
                        'TEXTTOHASH ='+ textToHash.toUppercase();
                if ((SHASIGN == calculatedHash) && (calculatedHash != '')) {
                    targetTransaction.get(0).Authorized__c = True;
                } else {
                    ExceptionLogger.sendException('E2EPaymentConfirmation Exception: Transaction authorization failed',
                            'SHASIGN = ' + SHASIGN + ' ||| ' + 'ACCEPTANCE = ' + acceptance + ' ||| ' + 'amount = ' + amount + ' ||| ' +
                                    'BRAND = ' + brand + ' ||| ' + 'CARDNO = ' + cardno + ' ||| ' + 'CN = ' + CN + ' ||| ' + 'currency = ' + currencyValue + ' ||| ' +
                                    'ED = ' + ED + ' ||| ' + 'NCERROR = ' + NCERROR + ' ||| ' + 'orderID = ' + orderID + ' ||| ' + 'PAYID = ' + payID + ' ||| ' +
                                    'PM = ' + paymentMethod + ' ||| ' + 'SCO_CATEGORY = ' + sco_category + ' ||| ' + 'SCORING = ' + scoring + ' ||| ' +
                                    'STATUS = ' + status + ' ||| ' + 'TRXDATE = ' + TRXDATE +' ||| '+ 'TEXTTOHASH ='+ textToHash.toUppercase());
                }
                update targetTransaction;
            } else {
                ExceptionLogger.sendException('E2EPaymentConfirmation Exception: Order not found',
                        'SHASIGN = ' + SHASIGN + ' ||| ' + 'ACCEPTANCE = ' + acceptance + ' ||| ' + 'amount = ' + amount + ' ||| ' +
                        'BRAND = ' + brand + ' ||| ' + 'CARDNO = ' + cardno + ' ||| ' + 'CN = ' + CN + ' ||| ' + 'currency = ' + currencyValue + ' ||| ' +
                        'ED = ' + ED + ' ||| ' + 'NCERROR = ' + NCERROR + ' ||| ' + 'orderID = ' + orderID + ' ||| ' + 'PAYID = ' + payID + ' ||| ' +
                        'PM = ' + paymentMethod + ' ||| ' + 'SCO_CATEGORY = ' + sco_category + ' ||| ' + 'SCORING = ' + scoring + ' ||| ' +
                        'STATUS = ' + status + ' ||| ' + 'TRXDATE = ' + TRXDATE +' ||| ');
            }
        } catch(Exception e) {
            ExceptionLogger.sendException('E2EPaymentConfirmation Exception '+String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }

    }

    private static String getCustomSettingName(Id opportunityId) {
        String result = '';

        List<Opportunity> targetOpportunity = [
                SELECT ID, Account.BillingCountry, Account.ShippingCountry
                FROM Opportunity
                WHERE  ID = :opportunityId
        ];

        if (targetOpportunity.size() == 1) {
            if (targetOpportunity.get(0).Account.BillingCountry == 'Germany') {
                result = 'E2EForm';
            } else if (targetOpportunity.get(0).Account.BillingCountry == 'Netherlands') {
                result = 'E2EFormNL';
            } else if (targetOpportunity.get(0).Account.BillingCountry == 'Belgium-NL') {
                result = 'E2EFormBENL';
            } else if (targetOpportunity.get(0).Account.BillingCountry == 'Belgium-FR') {
                result = 'E2EFormBEFR';
            } else if (targetOpportunity.get(0).Account.BillingCountry == 'Switzerland-DE') {
                result = 'E2EFormCHDE';
            } else if (targetOpportunity.get(0).Account.BillingCountry == 'France') {
                result = 'E2EFormFR';
            } else if (targetOpportunity.get(0).Account.BillingCountry == 'Poland') {
                result = 'E2EFormPL';
            } else if (targetOpportunity.get(0).Account.BillingCountry == 'Austria') {
                result = 'E2EFormAT';
            }
        }

        return result;
    }
}