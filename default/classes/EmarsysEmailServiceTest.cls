@isTest
private class EmarsysEmailServiceTest {


    /*******************************************************************************
	*  Name            : testInboundEmail()
	*  Summary         : test emails from Emarsys
	*  CreatedDate     : 21/08v/2017
	*  Parameters      :
	*  Returns         : void
	******************************************************************************/
	@isTest
    static void testInboundEmail() {
		Messaging.InboundEmail leadEmail = new Messaging.InboundEmail();
		Messaging.InboundEnvelope leadEnvelope = new Messaging.InboundEnvelope();
		leadEmail.htmlBody = '^^Test^^**Test**%%Lead%%';
		leadEmail.fromAddress ='emarsyswe@fleetcor.de';

		EmarsysEmailService serviceObject = new EmarsysEmailService();
		serviceObject.handleInboundEmail(leadEmail, leadEnvelope);

		Messaging.InboundEmail opportunityEmail = new Messaging.InboundEmail();
		Messaging.InboundEnvelope opportunityEnvelope = new Messaging.InboundEnvelope();
		opportunityEmail.htmlBody = '^^Test^^**Test**%%Opportunity%%';
		opportunityEmail.fromAddress ='emarsyswe@fleetcor.de';

		EmarsysEmailService opportunityServiceObject = new EmarsysEmailService();
		serviceObject.handleInboundEmail(opportunityEmail, opportunityEnvelope);
   	}

	/*******************************************************************************
	*  Name            : testInboundEmail2()
	*  Summary         : test emails from Emarsys
	*  CreatedDate     : 21/08v/2017
	*  Parameters      :
	*  Returns         : void
	******************************************************************************/
	@isTest
	static void testInboundEmail2() {
		Messaging.InboundEmail leadEmail = new Messaging.InboundEmail();
		Messaging.InboundEnvelope leadEnvelope = new Messaging.InboundEnvelope();
		leadEmail.htmlBody = '^^Test^^**Test**&&Lead&&';
		leadEmail.fromAddress ='emarsyswe@fleetcor.de';

		EmarsysEmailService serviceObject = new EmarsysEmailService();
		serviceObject.handleInboundEmail(leadEmail, leadEnvelope);

		Messaging.InboundEmail opportunityEmail = new Messaging.InboundEmail();
		Messaging.InboundEnvelope opportunityEnvelope = new Messaging.InboundEnvelope();
		opportunityEmail.htmlBody = '^^Test^^**Test**&&Opportunity&&';
		opportunityEmail.fromAddress ='emarsyswe@fleetcor.de';

		EmarsysEmailService opportunityServiceObject = new EmarsysEmailService();
		serviceObject.handleInboundEmail(opportunityEmail, opportunityEnvelope);
	}
}