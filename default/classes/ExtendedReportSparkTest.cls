@IsTest
public class ExtendedReportSparkTest {

    @IsTest
    static void testParse() {
        ExtendedReportSpark report = new ExtendedReportSpark();
        System.assert(report != null);

        ExtendedReportSpark.Leader objLeader = new ExtendedReportSpark.Leader();
        System.assert(objLeader != null);
        System.assert(objLeader.actualDate == null);
        System.assert(objLeader.fio == null);
        System.assert(objLeader.position == null);
        System.assert(objLeader.inn == null);

        ExtendedReportSpark.Address objAddress = new ExtendedReportSpark.Address();
        System.assert(objAddress != null);
        System.assert(objAddress.postCode == null);
        System.assert(objAddress.address == null);
        System.assert(objAddress.actualDate == null);
        System.assert(objAddress.fiasGUID == null);
        System.assert(objAddress.fiasCode == null);
        System.assert(objAddress.fiasRegion == null);
        System.assert(objAddress.fiasArea == null);
        System.assert(objAddress.fiasCity == null);
        System.assert(objAddress.fiasPlace == null);
        System.assert(objAddress.fiasPlan == null);
        System.assert(objAddress.fiasStreet == null);
        System.assert(objAddress.housing == null);
        System.assert(objAddress.block == null);
        System.assert(objAddress.room == null);
        System.assert(objAddress.businessCenterName == null);
        System.assert(objAddress.region == null);
        System.assert(objAddress.rayon == null);
        System.assert(objAddress.city == null);
        System.assert(objAddress.streetName == null);
        System.assert(objAddress.buildingNumber == null);

        ExtendedReportSpark objExtendedReportSpark = new ExtendedReportSpark();
        System.assert(objExtendedReportSpark != null);
        System.assert(objExtendedReportSpark.sparkID == null);
        System.assert(objExtendedReportSpark.companyType == null);
        System.assert(objExtendedReportSpark.status == null);
        System.assert(objExtendedReportSpark.isActing == null);
        System.assert(objExtendedReportSpark.dateFirstReg == null);
        System.assert(objExtendedReportSpark.shortNameRus == null);
        System.assert(objExtendedReportSpark.shortNameEn == null);
        System.assert(objExtendedReportSpark.fullNameRus == null);
        System.assert(objExtendedReportSpark.normName == null);
        System.assert(objExtendedReportSpark.guid == null);
        System.assert(objExtendedReportSpark.inn == null);
        System.assert(objExtendedReportSpark.kpp == null);
        System.assert(objExtendedReportSpark.ogrn == null);
        System.assert(objExtendedReportSpark.okpo == null);
        System.assert(objExtendedReportSpark.bik == null);
        System.assert(objExtendedReportSpark.okato == null);
        System.assert(objExtendedReportSpark.okfs == null);
        System.assert(objExtendedReportSpark.oktmo == null);
        System.assert(objExtendedReportSpark.okogu == null);
        System.assert(objExtendedReportSpark.okopf == null);
        System.assert(objExtendedReportSpark.charterCapital == null);
        System.assert(objExtendedReportSpark.leaderList == null);
        System.assert(objExtendedReportSpark.legalAddresses == null);
        System.assert(objExtendedReportSpark.email == null);
        System.assert(objExtendedReportSpark.www == null);
        System.assert(objExtendedReportSpark.workersRange == null);
        System.assert(objExtendedReportSpark.egrpoincluded == null);
        System.assert(objExtendedReportSpark.fcsmcode == null);

        ExtendedReportSpark.Okved objOkved = new ExtendedReportSpark.Okved();
        System.assert(objOkved != null);
        System.assert(objOkved.code == null);
        System.assert(objOkved.name == null);
        System.assert(objOkved.isMain == null);

        ExtendedReportSpark.Oktmo objOktmo = new ExtendedReportSpark.Oktmo();
        System.assert(objOktmo != null);
        System.assert(objOktmo.code == null);

        ExtendedReportSpark.Status objStatus = new ExtendedReportSpark.Status();
        System.assert(objStatus != null);
        System.assert(objStatus.dateD == null);
        System.assert(objStatus.type_Z == null);
        System.assert(objStatus.code == null);

        ExtendedReportSpark.Okopf objOkopf = new ExtendedReportSpark.Okopf();
        System.assert(objOkopf != null);
        System.assert(objOkopf.code == null);
        System.assert(objOkopf.name == null);
        System.assert(objOkopf.codeNew == null);

        ExtendedReportSpark.ListName objListName = new ExtendedReportSpark.ListName();
        System.assert(objListName != null);
        System.assert(objListName.content == null);
        System.assert(objListName.id == null);
        System.assert(objListName.isNegative == null);

        ExtendedReportSpark.Okogu objOkogu = new ExtendedReportSpark.Okogu();
        System.assert(objOkogu != null);
        System.assert(objOkogu.code == null);
        System.assert(objOkogu.name == null);

        ExtendedReportSpark.Okato objOkato = new ExtendedReportSpark.Okato();
        System.assert(objOkato != null);
        System.assert(objOkato.code == null);
        System.assert(objOkato.regionName == null);
        System.assert(objOkato.regionCode == null);

        ExtendedReportSpark.LegalAddresses objLegalAddresses = new ExtendedReportSpark.LegalAddresses();
        System.assert(objLegalAddresses != null);
        System.assert(objLegalAddresses.address == null);

        ExtendedReportSpark.LeaderList objLeaderList = new ExtendedReportSpark.LeaderList();
        System.assert(objLeaderList != null);
        System.assert(objLeaderList.leader == null);
    }

    @IsTest
    static void testGetMainOkved() {
        //No Okved data
        ExtendedReportSpark extendedReportSpark = new ExtendedReportSpark();
        System.assertEquals(null, extendedReportSpark.okved2List);
        System.assertEquals(null, extendedReportSpark.getMainOkved().name);
    }
}