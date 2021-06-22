public with sharing class EmarsysUtils {
	/*******************************************************************************
	*  Name            : generateRequestToEmarsys()
	*  Summary         : generate request for authorization to Emarsys    
	*  CreatedDate     : 03/02/2017
	*  Parameters      : 
	*  Returns         : String
	******************************************************************************/
    public static String generateRequestToEmarsys() {
	    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
	    String randStr = '';
	    while (randStr.length() < 32) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
	       randStr += chars.substring(idx, idx+1);
	    }
	    String username = 'PPR_EU001';
	    String secretKey = 'p76hSjYJcQjWKysyuiWq';
	    String nonce = randStr;
	    String timestamp = Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
	    String text = nonce + timestamp + secretKey;
	    String sha1 = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(text)));
	    Blob b64Blob = Blob.valueOf(sha1);
	    String passwordDigest = EncodingUtil.base64Encode(b64Blob);
	    String finalString = 'UsernameToken Username="' + username + '",PasswordDigest="' + passwordDigest + '",Nonce="' + nonce + '",Created="' + timestamp + '"';
	    return finalString;
    }
}