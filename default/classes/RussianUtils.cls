public class RussianUtils {
    public static final String SOLE_PROPRIETOR = 'Индивидуальный предприниматель';
    public static final String SOLE_PROPRIETOR_SHORT = 'ИП';

    public static String mergeContactFullNameInRussianFormat(String lastName, String firstName, String middleName) {
        List<String> nameParts = new List<String>();
        if (lastName != null) {
            nameParts.add(lastName);
        }

        if (firstName != null) {
            nameParts.add(firstName);
        }

        if (middleName != null) {
            nameParts.add(middleName);
        }

        String fullName = String.join(nameParts, ' ');
        return fullName;
    }

    public static List<String> parseContactNameByWhitespaces(String fullName, Integer maxNamePartsCount) {
        List<String> nameParts;
        if (!String.isBlank(fullName) && maxNamePartsCount != null) {
            nameParts = fullName.split('\\s+', maxNamePartsCount);
        }
        return nameParts;
    }
}