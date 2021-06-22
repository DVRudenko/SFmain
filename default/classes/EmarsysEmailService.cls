global class EmarsysEmailService implements Messaging.InboundEmailHandler {

	/*******************************************************************************
	*  Name            : handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
	*  Summary         : get emails from Emarsys
	*  CreatedDate     : 10/02/2017
	*  Parameters      : Messaging.inboundEmail email, Messaging.InboundEnvelope env
	*  Returns         : Messaging.InboundEmailResult
	******************************************************************************/
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
		String emailName = '';
		String campaignName = '';
		String contactType = '';
		try {
			Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
			String htmlTextBody = email.htmlBody;
			if (email.fromAddress == 'emarsyswe@fleetcor.de' || email.fromAddress == 'emarsyswetest@fleetcor.de') {
				if (htmlTextBody.substringBetween('^^') != null) {
					emailName = htmlTextBody.substringBetween('^^');
				}

				if (htmlTextBody.substringBetween('**') != null) {
					campaignName = htmlTextBody.substringBetween('**');
				}

				if (htmlTextBody.substringBetween('%%') != null) {
					contactType = htmlTextBody.substringBetween('%%');
				}
				else if (htmlTextBody.substringBetween('&&') != null){
					contactType = htmlTextBody.substringBetween('&&');
				}

				if ((contactType == 'Lead' || contactType == 'Opportunity') && emailName != '') {
					Datetime timeLaps = system.now().addMinutes(-6); //time range for check creating logs job
					String jobLogName = 'Emarsys EU Creating Logs "' + emailName + '"';
					List<CronTrigger> creatingLogs = [
							SELECT Id, CronJobDetail.Name, CreatedDate
							FROM CronTrigger
							WHERE CronJobDetail.Name LIKE :jobLogName +'%'
							AND CreatedDate > :timeLaps
					];

					if(creatingLogs.isEmpty()){
						String schedule = datetime.now().addMinutes(10).second() + ' ' + datetime.now().addMinutes(10).minute() + ' ' + datetime.now().addMinutes(10).hour() + ' '
								+ datetime.now().addMinutes(10).day() + ' ' + datetime.now().addMinutes(10).month() + ' ? ' + datetime.now().addMinutes(10).year();
						String scheduleName = jobLogName + ' ' +
								datetime.now().addMinutes(10).year() + '/' + datetime.now().addMinutes(10).month() + '/' +
								datetime.now().addMinutes(10).day() + ' ' + datetime.now().addMinutes(10).hour() + '/' +
								datetime.now().addMinutes(10).minute() + '/' +	datetime.now().addMinutes(10).second() + '/' +
								datetime.now().addMinutes(10).millisecond();

						System.schedule(scheduleName, schedule, new EmarsysAllLogsSchedule(emailName, campaignName, contactType));
					}
				}
			}
			result.success = true;
			return result;
		} catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()) + ' ' + emailName + ' ' + campaignName + ' ' + contactType, String.valueOf(e.getStackTraceString()));
            return null;
        }
	}
}