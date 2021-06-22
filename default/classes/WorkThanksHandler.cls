/**
 * Created by Andrei.Moiseev on 28.11.2017.
 */
public class WorkThanksHandler {
	// Regex string for parser input stirng
	//private static final String regex = '^Date=\'([0-9]{1,2}).([0-9]{1,2}).([0-9]{4})\'\\s*(.+)$';
	private static final String regex = '^Date=(\\D{1})([0-9]{1,2}).([0-9]{1,2}).([0-9]{4})(\\D{1})\\s*(.+)*$';

	/*******************************************************************************
	*  Name            : parserWorkThanksMessage()
	*  Summary         : parser message field from WorkThanks and separates the date and message
	*  CreatedDate     : 28/11/2017
	*  Parameters      : newWorkThanksList - new List WorkThanks
	*  Returns         : void
	******************************************************************************/
	public static void parserWorkThanksMessage(List<WorkThanks> newWorkThanksList) {
		Pattern regexPattern = Pattern.compile(regex);

		for(WorkThanks item : newWorkThanksList) {
			System.debug('item.Message');
			System.debug(item.Message);
			String message = item.Message;
			Matcher regexMatcher = regexPattern.matcher(message);
			regexMatcher.find();

			System.debug('regexMatcher.groupCount()');
			System.debug(regexMatcher.groupCount());
            for (Integer i = 0; i < regexMatcher.groupCount(); i++) {
                System.debug('i = ' + i); 
            	System.debug(regexMatcher.group(i));    
            }
            item.DateOfAppointment__c = parserOfDate(regexMatcher);
			item.Message = regexMatcher.group(6);
		}
	}

	private static Date parserOfDate(Matcher regexMatcher) {
		String month = regexMatcher.group(2);
		String day = regexMatcher.group(3);
		String year = regexMatcher.group(4);
        if (UserInfo.getLanguage() == 'ru') {
			day = regexMatcher.group(2);
            month = regexMatcher.group(3);
        }
		String newDate = year + '-' + month + '-' + day;
		Date dateOfAppointment;
        try {
            dateOfAppointment = Date.valueOf(newDate);
        } catch (System.TypeException e) {
            newDate = year + '-' + day + '-' + month;
            dateOfAppointment = Date.valueOf(newDate);
        }
		return dateOfAppointment;
	}
}