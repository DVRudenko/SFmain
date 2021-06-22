@IsTest
public class FinancialReportSparkTest {

    @IsTest
    static void test() {
        FinancialReportSpark objFinancialReportSpark = new FinancialReportSpark();
        System.assert(objFinancialReportSpark != null);
        System.assert(objFinancialReportSpark.sparkID == null);
        System.assert(objFinancialReportSpark.inn == null);
        System.assert(objFinancialReportSpark.ogrn == null);
        System.assert(objFinancialReportSpark.okpo == null);
        System.assert(objFinancialReportSpark.shortName == null);
        System.assert(objFinancialReportSpark.period == null);
        System.assert(objFinancialReportSpark.egrullikvidation == null);
        System.assert(objFinancialReportSpark.egrpoincluded == null);

        FinancialReportSpark.Form objForm = new FinancialReportSpark.Form();
        System.assert(objForm != null);
        System.assert(objForm.value == null);
        System.assert(objForm.id == null);
        System.assert(objForm.power == null);

        FinancialReportSpark.Value objValue = new FinancialReportSpark.Value();
        System.assert(objValue != null);
        System.assert(objValue.value == null);
        System.assert(objValue.code == null);
        System.assert(objValue.name == null);
        System.assert(objValue.column == null);

        FinancialReportSpark.Period objPeriod = new FinancialReportSpark.Period();
        System.assert(objPeriod != null);
        System.assert(objPeriod.form == null);
        System.assert(objPeriod.periodName == null);
        System.assert(objPeriod.dateEnd == null);
        System.assert(objPeriod.dateBegin == null);
    }

    @IsTest
    private static void testSort() {
        List<FinancialReportSpark> reports = new List<FinancialReportSpark>();
        FinancialReportSpark report1 = new FinancialReportSpark();
        report1.period = new FinancialReportSpark.Period();
        report1.period.dateEnd = '2017-12-30T21:00:00.000+0000';
        reports.add(report1);
        FinancialReportSpark report2 = new FinancialReportSpark();
        report2.period = new FinancialReportSpark.Period();
        report2.period.dateEnd = '2019-11-30T21:00:00.000+0000';
        reports.add(report2);
        FinancialReportSpark report3 = new FinancialReportSpark();
        report3.period = new FinancialReportSpark.Period();
        report3.period.dateEnd = '2019-12-31T21:00:00.000+0000';
        reports.add(report3);

        reports.sort();
        System.assertEquals('2019-12-31T21:00:00.000+0000', reports.get(0).period.dateEnd);
        System.assertEquals('2019-11-30T21:00:00.000+0000', reports.get(1).period.dateEnd);
        System.assertEquals('2017-12-30T21:00:00.000+0000', reports.get(2).period.dateEnd);

    }

}