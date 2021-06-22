@IsTest
public with sharing class ConverterRUTest {

    @IsTest
    private static void testToWords() {
        Converter converter = new ConverterRU();

        String convertedNumber = converter.toWords(100000);
        System.assertEquals('сто тысяч', convertedNumber);

        convertedNumber = converter.toWords(0);
        System.assertEquals('ноль', convertedNumber);

        convertedNumber = converter.toWords(1000000);
        System.assertEquals('один миллион', convertedNumber);

        convertedNumber = converter.toWords(90015);
        System.assertEquals('девяносто тысяч пятнадцать', convertedNumber);

        convertedNumber = converter.toWords(205568);
        System.assertEquals('двести пять тысяч пятьсот шестьдесят восемь', convertedNumber);

        convertedNumber = converter.toWords(946800);
        System.assertEquals('девятьсот сорок шесть тысяч восемьсот', convertedNumber);

        convertedNumber = converter.toWords(2004);
        System.assertEquals('две тысячи четыре', convertedNumber);

        convertedNumber = converter.toWords(40);
        System.assertEquals('сорок', convertedNumber);

        convertedNumber = converter.toWords(910025);
        System.assertEquals('девятьсот десять тысяч двадцать пять', convertedNumber);

        convertedNumber = converter.toWords(156);
        System.assertEquals('сто пятьдесят шесть', convertedNumber);

        convertedNumber = converter.toWords(-1);
        System.assertEquals('', convertedNumber);

        convertedNumber = converter.toWords(null);
        System.assertEquals('', convertedNumber);

        convertedNumber = converter.toWords(4000000);
        System.assertEquals('четыре миллиона', convertedNumber);

        convertedNumber = converter.toWords(115000);
        System.assertEquals('сто пятнадцать тысяч', convertedNumber);
    }

    @IsTest
    private static void testToWordAccordingCase_GenitiveCase() {
        Converter converter = new ConverterRU();

        String convertedNumber = converter.toWordsAccordingCase(0, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('ноля', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(1, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('одного', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(3, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('трёх', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(5, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('пяти', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(22, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('двадцати двух', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(22, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('двадцати двух', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(44, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('сорока четырёх', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(56, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('пятидесяти шести', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(97, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('девяноста семи', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(109, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('ста девяти', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(210, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('двухсот десяти', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(564, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('пятисот шестидесяти четырёх', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(1003, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('одной тысячи трёх', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(2002, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('двух тысяч двух', convertedNumber);

        convertedNumber = converter.toWordsAccordingCase(6006, ConverterRUConstants.RUSSIAN_CASE.GENITIVE);
        System.assertEquals('шести тысяч шести', convertedNumber);
    }
}