public with sharing class E2EFormEncryption {

    /*******************************************************************************
    *  Name            : getHashAlgorithmStringSHA1()
    *  Summary         : return hash string by algoritm SHA1
    *  CreatedDate     : 28/02/2018
    *  Parameters      : inputString - string for hashing
    *  Returns         : String
    ******************************************************************************/
    public static String getHashAlgorithmStringSHA1(String inputString) {
        Blob inputBlob = Blob.valueOf(inputString);
        Blob inputHashBlob = Crypto.generateDigest('SHA1', inputBlob);
        String resultString = EncodingUtil.convertToHex(inputHashBlob);
        return resultString;
    }

    /*******************************************************************************
    *  Name            : getHashAlgorithAES256()
    *  Summary         : return hash encrypted64 string by algoritm AES256
    *  CreatedDate     : 28/02/2018
    *  Parameters      : inputString - string for hashing
    *                    keyAES256 - key to encrypt (Custom Setting parameters)
    *  Returns         : String
    ******************************************************************************/
    public static String getHashAlgorithAES256(Blob keyAES256, String inputString) {
        Blob source = Blob.valueOf(inputString);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', keyAES256, source);
        String encrypted64 = EncodingUtil.base64Encode(encrypted);
        encrypted64 = encrypted64.replace('+','%2B');
        return encrypted64;
    }


    /*******************************************************************************
    *  Name            : decodeHashAlgorithmAES256()
    *  Summary         : return decode string (algoritm AES256)
    *  CreatedDate     : 28/02/2018
    *  Parameters      : inputString - string for hashing
    *                    keyAES256 - key from encrypt (Custom Setting parameters)
    *  Returns         : String
    ******************************************************************************/
    public static String decodeHashAlgorithmAES256(Blob keyAES256, String inputString) {
        inputString = inputString.replace('%2B','+');
        Blob dest = EncodingUtil.base64Decode(inputString);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', keyAES256, dest);
        String decryptedText = decrypted.toString();
        return decryptedText;
    }

}