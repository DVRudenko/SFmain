@RestResource(urlMapping='/PayUResult')
global class E2EPayUConfirmation {
    @HttpPost
    global static void getPayUInformation() {
        try {
            PayUResultEntity paymentResult = PayUResultEntity.parse(RestContext.request.requestBody.toString());
            String payUOrderId = paymentResult.order.orderId;

            List<Payment_Transaction__c> paymmentTransactionList = [
                    SELECT Id, Amount__c, BuyerCustomerId__c, BuyerEmail__c, BuyerFirstName__c, BuyerLastName__c, BuyerPhone__c, MerchantPosId__c, 
                            PaymentMethod__c, PayUOrderId__c, Status__c 
                    FROM Payment_Transaction__c 
                    WHERE PayUOrderId__c = :payUOrderId
                    LIMIT 1];

            if ( ! paymmentTransactionList.isEmpty()) {
                if (paymentResult.order.buyer != null) {
                    paymmentTransactionList.get(0).BuyerEmail__c = paymentResult.order.buyer.email;
                    paymmentTransactionList.get(0).BuyerFirstName__c = paymentResult.order.buyer.firstName;
                    paymmentTransactionList.get(0).BuyerLastName__c = paymentResult.order.buyer.lastName;
                    paymmentTransactionList.get(0).BuyerPhone__c = paymentResult.order.buyer.phone;
                    paymmentTransactionList.get(0).BuyerCustomerId__c = paymentResult.order.buyer.customerId;
                } 
                paymmentTransactionList.get(0).MerchantPosId__c = paymentResult.order.merchantPosId;
                if (paymentResult.order.payMethod != null) {
                    paymmentTransactionList.get(0).PaymentMethod__c = paymentResult.order.payMethod.type;
                }
                paymmentTransactionList.get(0).Status__c = paymentResult.order.status;
                update paymmentTransactionList;
            } else {
                ExceptionLogger.sendException('E2EPayUConfirmation Exception: Order not found', 'orderId = ' + payUOrderId);
            }
        } catch (Exception e) {
            ExceptionLogger.sendException('E2EPayUConfirmation Exception ' + String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }
}