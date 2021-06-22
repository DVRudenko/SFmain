@IsTest
public class SoleProprietorSparkTest {

    @isTest
    static void testParse() {
        String json = '{\"sparkID\":35976714,\"status\":{\"isActing\":true,\"text\":\"Действующее\",\"code\":24},' +
                '\"dateReg\":\"2009-08-25T21:00:00.000+0000\",\"fullNameRus\":\"Иванов Иван Иваныч\",' +
                '\"inn\":\"770605086142\",\"ogrnip\":\"309774623800678\",\"okpo\":\"0116896779\",' +
                '\"okato\":{\"code\":\"45286596000\",\"regionName\":\"Москва\",\"regionCode\":45},\"' +
                'birthDate\":\"1979-03-12T21:00:00.000+0000\",\"birthPlace\":\"г. Москва\",\"okvedlist\"' +
                ':{\"okved\":[{\"code\":\"74.14\",\"name\":\"Консультирование по вопросам коммерческой деятельности и управления\",' +
                '\"isMain\":true},{\"code\":\"51.16\",\"name\":\"Деятельность агентов по оптовой торговле текстильными изделиями, одеждой, обувью, изделиями из кожи и меха\",' +
                '\"isMain\":null},{\"code\":\"51.42\",\"name\":\"Оптовая торговля одеждой, включая нательное белье, и обувью\",' +
                '\"isMain\":null},{\"code\":\"51.47\",\"name\":\"Оптовая торговля прочими непродовольственными потребительскими товарами\",' +
                '\"isMain\":null},{\"code\":\"52.4\",\"name\":\"Прочая розничная торговля в специализированных магазинах\",' +
                '\"isMain\":null},{\"code\":\"52.42\",\"name\":\"Розничная торговля одеждой\",\"isMain\":null},' +
                '{\"code\":\"52.48.39\",\"name\":\"Специализированная розничная торговля прочими непродовольственными  товарами, не включенными в другие группировки\",' +
                '\"isMain\":null},{\"code\":\"52.61.2\",\"name\":\"Розничная торговля, осуществляемая непосредственно при помощи телевидения, радио, телефона и Интернет\",' +
                '\"isMain\":null},{\"code\":\"74.40\",\"name\":\"Рекламная деятельность\",\"isMain\":null},' +
                '{\"code\":\"80.42\",\"name\":\"Образование для взрослых и прочие виды образования, не включенные в другие группировки\",\"isMain\":null}]}}';
        SoleProprietorSpark obj = SoleProprietorSpark.parse(json);
        System.assert(obj != null);
    }

    @IsTest
    static void testGetMainOkved() {
        //No Okved data
        String json = '{\"sparkID\":35976714,\"status\":{\"isActing\":true,\"text\":\"Действующее\",\"code\":24},' +
                '\"dateReg\":\"2009-08-25T21:00:00.000+0000\",\"fullNameRus\":\"Иванов Иван Иваныч\",' +
                '\"inn\":\"770605086142\",\"ogrnip\":\"309774623800678\",\"okpo\":\"0116896779\",' +
                '\"okato\":{\"code\":\"45286596000\",\"regionName\":\"Москва\",\"regionCode\":45},\"' +
                'birthDate\":\"1979-03-12T21:00:00.000+0000\",\"birthPlace\":\"г. Москва\"}';
        SoleProprietorSpark soleProprietorSpark = SoleProprietorSpark.parse(json);
        System.assertEquals(null, soleProprietorSpark.getMainOkved().name);
    }

}