public interface Converter {
    String toWords(Integer inputNumber);

    String toWordsAccordingCase(Integer inputNumber, ConverterRUConstants.RUSSIAN_CASE selectedCase);
}