trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        EmailMessageHandler.inputRecipientsAsToEmailAddressesInEmailMessage(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        EmailMessageHandler.processMessagesToClosedCase(Trigger.new);
        EmailMessageHandler.updateRelatedCases(Trigger.new);
    }
}