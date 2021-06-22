global class EmailToLeadFranceService implements Messaging.InboundEmailHandler {
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
	                                                  Messaging.InboundEnvelope env){
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		String htmlTextBody = email.htmlBody;
		String plainTextBody = email.plainTextBody;
		if (plainTextBody.contains('Spam') || plainTextBody.contains('spam')) {
			return null;
		}
		RecordType leadRecordType = [
				SELECT Id
				FROM RecordType
				WHERE Name = 'Endkunde' AND SobjectType = 'Lead'];
		Lead newLead = new Lead(
			RecordTypeId = leadRecordType.Id,
			Sec_Channel__c = 'Inbound',
			Country = 'France',
			Channel__c = 'Internet',
			LeadSource = 'Referral');
		// newLead.Company = htmlTextBody.substringBetween('<td class="tdleft">Nom</td><td class="tdright">', '</td>');
		// newLead.Adresszusatz__c = htmlTextBody.substringBetween('<td class="tdleft">Adresse</td><td class="tdright">', '</td>');
		// newLead.Street = htmlTextBody.substringBetween('<td class="tdleft">Ville</td><td class="tdright">', '</td>');
		// newLead.Phone = htmlTextBody.substringBetween('<td class="tdleft">Téléphone</td><td class="tdright"><a href="tel://', '" style="color:purple">');
		// newLead.MobilePhone = htmlTextBody.substringBetween('</a> - <a href="tel://', '" style="color:purple">');
		// newLead.Handelsregister__c = htmlTextBody.substringBetween('<td class="tdleft">SIRET</td><td class="tdright"><a href=', '" style="color:purple">');
		// newLead.Beschaeftigte__c = htmlTextBody.substringBetween('<td class="tdleft">SIRET</td><td class="tdright">"', '');
		// newLead.Description = '';
		// newLead.Description = htmlTextBody.substringBetween('<td class="tdleft">INFORMATIONS Business CRT</td><td class="tdright">', '</td>');
		// newLead.Description = newLead.Description + ' ' +
		// 	htmlTextBody.substringBetween('<td class="tdleft">Nous sommes bien au siège / Responsable des Achats</td><td class="tdright">', '</td>');
		// newLead.Monatlicher_Kraftstoffverbrauch_in_Liter__c = Decimal.valueOf(htmlTextBody.substringBetween('<td class="tdleft">Volume Total</td><td class="tdright">', 'm3</td>'));
		// newLead.Anzahl_PKW__c = Decimal.valueOf(htmlTextBody.substringBetween('<td class="tdleft">Nombre PL</td><td class="tdright">', '</td>'));
		
		// String nombreVL = htmlTextBody.substringBetween('<td class="tdleft">Nombre VL</td><td class="tdright">', '</td>');
		// nombreVL = nombreVL.trim();
		// if ( ! String.isEmpty(nombreVL)) {
		// 	newLead.Anzahl_LKW__c = Decimal.valueOf(nombreVL);	
		// }
		
		// newLead.Welche_Tankkarten__c = htmlTextBody.substringBetween('<td class="tdleft">Concurrence</td><td class="tdright">', '</td>');
		// newLead.Description = newLead.Description + ' \nBase Vrac: ' + htmlTextBody.substringBetween('<td class="tdleft">Base Vrac</td><td class="tdright">', '</td>');
		// newLead.Description = newLead.Description + ' \nType de Transport: ' + htmlTextBody.substringBetween('<td class="tdleft">Type de Transport</td><td class="tdright">', '</td>');
		// newLead.Description = newLead.Description + ' \nGroupement Achats: ' + htmlTextBody.substringBetween('<td class="tdleft">Groupement Achats</td><td class="tdright">', '</td>');
		// newLead.Umsatzsteuer_ID__c = htmlTextBody.substringBetween('<td class="tdleft">No TVA</td><td class="tdright">', '</td>');
		// newLead.Salutation = htmlTextBody.substringBetween('<td class="tdleft">Titre</td><td class="tdright">', '</td>');
		// newLead.LastName = htmlTextBody.substringBetween('<td class="tdleft">Nom du Contact</td><td class="tdright">', '</td>');
		// newLead.Position_Funktion__c = htmlTextBody.substringBetween('<td class="tdleft">Poste Occupe</td><td class="tdright">', '</td>');
		// newLead.Email = htmlTextBody.substringBetween('<td class="tdleft">Email</td><td class="tdright">a href="mailto:', '" style="color:purple">');
		// newLead.Website = htmlTextBody.substringBetween('<td class="tdleft">Website</td><td class="tdright">', '</td>');
		// newLead.Description = newLead.Description + ' \nCommentaires: ' + htmlTextBody.substringBetween('<td class="tdleft">Commentaires</td><td class="tdright">', '</td>');
		
		////
		newLead.Company = plainTextBody.substringBetween('Nom ', '\n');
		newLead.Adresszusatz__c = plainTextBody.substringBetween('Adresse ', '\n');
		newLead.Street = plainTextBody.substringBetween('Ville ', '\n');
		newLead.Phone = plainTextBody.substringBetween('Téléphone ', ' <//');
		String phoneSubstringFormat = '<//' + newLead.Phone + '> - ';
		newLead.MobilePhone = plainTextBody.substringBetween(phoneSubstringFormat, ' <//');
		newLead.Handelsregister__c = plainTextBody.substringBetween('SIRET ', ' <//');
		newLead.Beschaeftigte__c = plainTextBody.substringBetween('TRANCHE EFFECTIF ', '\n');
		newLead.Description = '';
		newLead.Description = plainTextBody.substringBetween('INFORMATIONS Business CRT ', '\n');
		newLead.Description = newLead.Description + ' ' +
			plainTextBody.substringBetween('Nous sommes bien au siège / Responsable des Achats ', '\n');
		newLead.Monatlicher_Kraftstoffverbrauch_in_Liter__c = Decimal.valueOf(plainTextBody.substringBetween('Volume Total ', 'm3'));
		newLead.Anzahl_PKW__c = Decimal.valueOf(plainTextBody.substringBetween('Nombre PL ', '\n'));
		
		String nombreVL = plainTextBody.substringBetween('Nombre VL ', '\n');
		if ( ! String.isEmpty(nombreVL)) {
			newLead.Anzahl_LKW__c = Decimal.valueOf(nombreVL);	
		}
		
		// newLead.Welche_Tankkarten__c = plainTextBody.substringBetween('Concurrence ', '\n');
		newLead.Description = newLead.Description + ' \nBase Vrac: ' + plainTextBody.substringBetween('Base Vrac ', '\n');
		newLead.Description = newLead.Description + ' \nType de Transport: ' + plainTextBody.substringBetween('Type de Transport ', '\n');
		newLead.Description = newLead.Description + ' \nGroupement Achats: ' + plainTextBody.substringBetween('Groupement Achats ', '\n');
		newLead.Umsatzsteuer_ID__c = plainTextBody.substringBetween('No TVA ', '\n');
		newLead.Salutation = plainTextBody.substringBetween('Titre ', '\n');
		newLead.LastName = plainTextBody.substringBetween('Nom du Contact ', '\n');
		newLead.Position_Funktion__c = plainTextBody.substringBetween('Poste Occupe ', '\n');
		newLead.Email = plainTextBody.substringBetween('Email ', '\n');
		newLead.Website = plainTextBody.substringBetween('Website ', '\n');
		newLead.Description = newLead.Description + ' \nCommentaires: ' + plainTextBody.substringBetween('Commentaires ', '\n');
		newLead.Description = newLead.Description.replace('null','');


		insert newLead;
		// Set the result to true, no need to send an email back to the user
		// with an error message
		result.success = true;

		// Return the result for the Force.com Email Service
		return result;
	}
}