global class TwikeyEntity {
    global String key;
    global String url;
    global String mndtId;
    global List<Messages> Messages;
	global GrpHdr GrpHdr;

    global class Drtn {
        global Date FrDt;
    }

    global class Ocrncs {
        global String SeqTp;
        global String Frqcy;
        global Drtn Drtn;
    }

    global class CtctDtls {
        global String EmailAdr;
    }

    global class PstlAdr {
        global String AdrLine;
        global String PstCd;
        global String TwnNm;
        global String Ctry;
    }

    global class Dbtr {
        global CtctDtls CtctDtls;
        global String Nm;
        global String CtryOfRes;
        global PstlAdr PstlAdr;
    }

    global class Cdtr {
        global CtctDtls CtctDtls;
        global String Nm;
        global String CtryOfRes;
        global PstlAdr PstlAdr;
        global String Id;
    }

    global class FinInstnId {
        global String Nm;
        global String BICFI;
    }

    global class DbtrAgt {
        global FinInstnId FinInstnId;
    }

    global class SplmtryData {
        global String Key;
        global String Value;
    }

    global class Mndt {
        global Ocrncs Ocrncs;
        global Dbtr Dbtr;
        global String DbtrAcct;
        global String RfrdDoc;
        global String LclInstrm;
        global String CdtrSchmeId;
        global String MndtId;
        global Cdtr Cdtr;
        global DbtrAgt DbtrAgt;
        global List<SplmtryData> SplmtryData;
    }

    global class CxlRsn {
        global String EvtTime;
        global Mndt Mndt;
    }

    global class GrpHdr {
        global DateTime CreDtTm;
    }

    global class Messages {
        global String EvtTime;
        global Mndt Mndt;
        global CxlRsn CxlRsn;
        global String OrgnlMndtId;
    }

    global static TwikeyEntity parse(String jsonStr) {
		return (TwikeyEntity) JSON.deserialize(jsonStr, TwikeyEntity.class);
	}
}