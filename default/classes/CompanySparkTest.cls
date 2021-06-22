@isTest
public class CompanySparkTest {

    @isTest
    static void test() {
        CompanySpark company = new CompanySpark();
        company.sparkID = 6329708;
        company.inn = '7743676000';
        company.ogrn = '1087746118162';
        company.okpo = '84763430';
        company.fullName = 'ОБЩЕСТВО С ОГРАНИЧЕННОЙ ОТВЕТСТВЕННОСТЬЮ \"НКТ СОФТВЭР\"';
        company.address = 'г. Москва, ул. Зорге, д. 17';
        company.industry = 'Торговля оптовая легковыми автомобилями и легкими автотранспортными средствами';
        company.regionName = 'Москва';
        company.regionCode = '123456';
        company.manager = 'Управляющая компания ТД НКТ, ООО';
        company.okopfName = 'Общества с ограниченной ответственностью';

        System.assert(company != null);
        System.assert(company.sparkID != null);
        System.assert(company.inn != null);
        System.assert(company.ogrn != null);
        System.assert(company.okpo != null);
        System.assert(company.fullName != null);
        System.assert(company.address != null);
        System.assert(company.industry != null);
        System.assert(company.regionName != null);
        System.assert(company.regionCode != null);
        System.assert(company.manager != null);
        System.assert(company.okopfName != null);
    }
}