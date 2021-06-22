public class ConverterRU implements Converter {
    /*******************************************************************************
     *  Name            : toWords(Integer inputNumber)
     *  Summary         : convert number to word, from 1 to integer limit (2,147,483,647)
     *  CreatedDate     : 8/5/2020
     *  Parameters      : Integer inputNumber - number integer
     *  Returns         : String converted number
     ******************************************************************************/
    public String toWords(Integer numberForConvert) {
        return toWordsAccordingCase(numberForConvert, ConverterRUConstants.RUSSIAN_CASE.NOMINATIVE);
    }

    public String toWordsAccordingCase(Integer numberForConvert, ConverterRUConstants.RUSSIAN_CASE selectedCase) {
        if (numberForConvert < 0 || numberForConvert == null) {
            return '';
        }

        if (numberForConvert == 0) {
            return convertToProperCase(0, ConverterRUConstants.ZERO, selectedCase, 0);
        }

        List<Integer> segments = prepareSegments(numberForConvert);
        String convertedNumber = '';
        Integer segmentsSizeForMorph = segments.size() - 1;

        for (Integer i = 0; i < segments.size(); i++) {
            Integer sex = ConverterRUConstants.THOUSAND_EXPONENT_STEP_SEX_DEPENDENCIES.get(segmentsSizeForMorph);
            Integer currentSegment = segments.get(i);

            String currentSegmentString = prepareSegmentForNumbersDetecting(currentSegment);

            Integer firstDigit = Integer.valueOf(currentSegmentString.substring(0, 1));
            Integer secondDigit = Integer.valueOf(currentSegmentString.substring(1, 2));
            Integer thirdDigit = Integer.valueOf(currentSegmentString.substring(2, 3));
            Integer secondAndThirdDigit = Integer.valueOf(currentSegmentString.substring(1, 3));

            String digitInWord = '';

            if (currentSegment > 99) {
                digitInWord = ConverterRUConstants.HUNDRED_TO_THOUSAND_POSTFIXES[firstDigit];
                convertedNumber += convertToProperCase(currentSegment, digitInWord, selectedCase, sex) + ' ';
            }

            if (secondAndThirdDigit > 20) {
                digitInWord = ConverterRUConstants.TEN_TO_HUNDRED_POSTFIXES[secondDigit];
                convertedNumber += convertToProperCase(secondAndThirdDigit, digitInWord, selectedCase, sex) + ' ';

                convertedNumber += convertNumberBeforeTen(thirdDigit, selectedCase, sex);
            } else if (secondAndThirdDigit > 9) {
                digitInWord = ConverterRUConstants.TEN_TO_TWENTY_DIGITS[secondAndThirdDigit - 9];
                convertedNumber += convertToProperCase(secondAndThirdDigit, digitInWord, selectedCase, sex) + ' ';
            } else {
                convertedNumber += convertNumberBeforeTen(thirdDigit, selectedCase, sex);
            }

            if (currentSegment != 0 && segmentsSizeForMorph != 0) {
                String morphedWord = morphWord(currentSegment, ConverterRUConstants.THOUSAND_EXPONENT_STEP_POSTFIX.get(segmentsSizeForMorph));
                Integer currentSegmentStep = Integer.valueOf(Math.pow(1000, segmentsSizeForMorph) * currentSegment);
                convertedNumber += convertToProperCase(currentSegmentStep, morphedWord, selectedCase, sex)  + ' ';
            }
            
            segmentsSizeForMorph--;
            convertedNumber = convertedNumber.replaceAll(' {2,}', ' ');
        }

        convertedNumber = convertedNumber.replaceAll(' $', '');
        return convertedNumber;
    }

    private List<Integer> prepareSegments(Integer numberForConvert) {
        List<Integer> segments = new List<Integer>();
        while (numberForConvert > 999) {
            Integer seg = numberForConvert / 1000;
            segments.add(numberForConvert - (seg * 1000));
            numberForConvert = seg;
        }
        segments.add(numberForConvert);
        segments = reverseIntegerList(segments);

        return segments;
    }

    private String prepareSegmentForNumbersDetecting(Integer currentSegment) {
        String currentSegmentString = String.valueOf(currentSegment);
        if (currentSegmentString.length() == 1) {
            currentSegmentString = '00' + currentSegmentString;
        } else if (currentSegmentString.length() == 2) {
            currentSegmentString = '0' + currentSegmentString;
        }

        return currentSegmentString;
    }

    private String convertNumberBeforeTen(Integer digit, ConverterRUConstants.RUSSIAN_CASE selectedCase, Integer sex) {
        String digitInWord = ConverterRUConstants.TEN_DIGIT_SEX_DEPENDENCY.get(sex).get(digit);
        return convertToProperCase(digit, digitInWord, selectedCase, sex) + ' ';
    }

    private String morphWord(Integer currentSegment, List<String> stepPostfixes) {
        Integer n = Math.mod(currentSegment, 100);
        long n1 = Math.mod(n, 10);

        if (n > 10 && n < 20) {
            return stepPostfixes.get(2);
        } else if (n1 > 1 && n1 < 5) {
            return stepPostfixes.get(1);
        } else if (n1 == 1) {
            return stepPostfixes.get(0);
        } else {
            return stepPostfixes.get(2);
        }
    }

    private List<Integer> reverseIntegerList(List<Integer> listToReverse) {
        if (listToReverse == null || listToReverse.isEmpty()) {
            return listToReverse;
        }

        List<Integer> reversed = new List<Integer>();
        for (Integer i = listToReverse.size() - 1; i >= 0; i--) {
            reversed.add(listToReverse[i]);
        }

        return reversed;
    }

    private String convertToProperCase(Integer digit, String digitInWord, ConverterRUConstants.RUSSIAN_CASE selectedCase, Integer sex) {
        if (String.isBlank(digitInWord)) {
            return digitInWord;
        }
        
        if (digit == 1) {
            return digitInWord.substring(0, digitInWord.length() - 2) + ConverterRUConstants.CASE_POSTFIX_MAPPING_ONE.get(sex).get(selectedCase);
        } else if (digit == 2) { 
            return digitInWord.substring(0, digitInWord.length() - 1) + ConverterRUConstants.CASE_POSTFIX_MAPPING_TWO.get(sex).get(selectedCase);
        } else if (digit < 5) {
            return digitInWord.substring(0, digitInWord.length() - 1) + ConverterRUConstants.CASE_POSTFIX_MAPPING_EXCEPTIONS.get(digit).get(selectedCase);
        } else if (digit < 40) {
            return digitInWord.substring(0, digitInWord.length() - 1) + ConverterRUConstants.CASE_POSTFIX_MAPPING.get(selectedCase);
        } else if (digit > 39 && digit < 50) {
            return digitInWord + ConverterRUConstants.CASE_POSTFIX_MAPPING_EXCEPTIONS.get(40).get(selectedCase);
        } else if (digit > 89 && digit <100) {
            return digitInWord.substring(0, digitInWord.length() - 1) + ConverterRUConstants.CASE_POSTFIX_MAPPING_EXCEPTIONS.get(90).get(selectedCase);
        } else if (digit > 49 && digit < 90) {
            return constructFromFiftyToNinenty(digitInWord, selectedCase);
        } else if (digit < 200) {
            return (selectedCase == ConverterRUConstants.RUSSIAN_CASE.NOMINATIVE || selectedCase == ConverterRUConstants.RUSSIAN_CASE.ACCUSATIVE) ? digitInWord : ConverterRUConstants.HUNDRED_DIGIT_POSTFIX;
        } else if (digit < 1000) {
            return constructHundreds(digit, digitInWord, selectedCase, sex);
        } else if (digit < 1000000) {
            return digitInWord.substring(0, digitInWord.length() - 1) + ConverterRUConstants.THOUSAND_CASE_POSTFIXES.get(digitInWord).get(selectedCase);
        }
        // TODO: million

        return digitInWord;
    }

    private String constructFromFiftyToNinenty(String digitInWord, ConverterRUConstants.RUSSIAN_CASE selectedCase) {
        String postfix = ConverterRUConstants.CASE_POSTFIX_MAPPING.get(selectedCase);
        String firstDigit = digitInWord.removeEnd(ConverterRUConstants.TEN_DIGIT_POSTFIX);
        String tenPostfix = (selectedCase == ConverterRUConstants.RUSSIAN_CASE.NOMINATIVE || selectedCase == ConverterRUConstants.RUSSIAN_CASE.ACCUSATIVE) ? '' : postfix;

        return firstDigit.substring(0, firstDigit.length() - 1) + postfix + ConverterRUConstants.TEN_DIGIT_POSTFIX + tenPostfix;
    }

    private string constructHundreds(Integer digit, String digitInWord, ConverterRUConstants.RUSSIAN_CASE selectedCase, Integer sex) {
        if (selectedCase == ConverterRUConstants.RUSSIAN_CASE.NOMINATIVE || selectedCase == ConverterRUConstants.RUSSIAN_CASE.ACCUSATIVE) {
            return digitInWord;
        }

        Integer firstHundredDigit = digit / 100;
        String firstPart = convertToProperCase(firstHundredDigit, ConverterRUConstants.TEN_DIGIT_SEX_DEPENDENCY.get(sex).get(firstHundredDigit), selectedCase, sex);
        String secondPart = ConverterRUConstants.CASE_POSTFIX_HUNDRED_MAPPING.get(selectedCase);
        
        return firstPart + secondPart;
    }
}