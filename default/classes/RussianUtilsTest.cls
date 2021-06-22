@isTest
public class RussianUtilsTest {
    @isTest
    private static void mergeContactFullNameInRussianFormatTest() {
        String testFullName = RussianUtils.mergeContactFullNameInRussianFormat('Максимчик', 'Владислав', 'Эдуардович');
        system.assertEquals('Максимчик Владислав Эдуардович', testFullName);
    }
    @isTest
    private static void mergeContactFullNameInRussianFormatTest_nullEntryValues() {
        String testFullName = RussianUtils.mergeContactFullNameInRussianFormat(null, null, null);
        system.assertEquals('', testFullName);
    }

    @isTest
    private static void parseContactNameByWhitespacesTest() {
        String testFullName = 'Алехин     Сергей Викторович';
        List<String> testNameParts1 = RussianUtils.parseContactNameByWhitespaces(testFullName, 2);
        system.assertEquals('Алехин', testNameParts1[0]);
        system.assertEquals('Сергей Викторович', testNameParts1[1]);
        system.assertEquals(2, testNameParts1.size());

        List<String> testNameParts2 = RussianUtils.parseContactNameByWhitespaces(testFullName, 3);
        system.debug(testNameParts2);
        system.assertEquals('Алехин', testNameParts2[0]);
        system.assertEquals('Сергей', testNameParts2[1]);
        system.assertEquals('Викторович', testNameParts2[2]);
        system.assertEquals(3, testNameParts2.size());
    }

    @isTest
    private static void parseContactNameByWhitespacesTest_nullEntryValues() {
        List<String> testNameParts1 = RussianUtils.parseContactNameByWhitespaces(null, null);
        system.assertEquals(null, testNameParts1);
    }
}