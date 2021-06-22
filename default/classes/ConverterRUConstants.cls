public with sharing class ConverterRUConstants {
    public enum RUSSIAN_CASE {
        NOMINATIVE,
        GENITIVE,
        DATIVE,
        ACCUSATIVE,
        INSTRUMENTAL,
        PREPOSITIONAL
    }

    // 0 - MALE, 1 - FEMALE
    public static final Map<Integer, List<String>> TEN_DIGIT_SEX_DEPENDENCY = new Map<Integer, List<String>>{
        0 => new List<String>{ '', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять' },
        1 => new List<String>{ '', 'одна', 'две', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять' }
    };
    public static final List<String> TEN_TO_TWENTY_DIGITS = new List<String>{
        '',
        'десять',
        'одиннадцать',
        'двенадцать',
        'тринадцать',
        'четырнадцать',
        'пятнадцать',
        'шестнадцать',
        'семнадцать',
        'восемнадцать',
        'девятнадцать',
        'двадцать'
    };
    public static final List<String> TEN_TO_HUNDRED_POSTFIXES = new List<String>{
        '',
        'десять',
        'двадцать',
        'тридцать',
        'сорок',
        'пятьдесят',
        'шестьдесят',
        'семьдесят',
        'восемьдесят',
        'девяносто'
    };
    public static final List<String> HUNDRED_TO_THOUSAND_POSTFIXES = new List<String>{
        '',
        'сто',
        'двести',
        'триста',
        'четыреста',
        'пятьсот',
        'шестьсот',
        'семьсот',
        'восемьсот',
        'девятьсот'
    };
    public static final List<Integer> THOUSAND_EXPONENT_STEP_SEX_DEPENDENCIES = new List<Integer>{ 0, 1, 0, 0, 0 };
    public static final Map<Integer, List<String>> THOUSAND_EXPONENT_STEP_POSTFIX = new Map<Integer, List<String>>{
        0 => new List<String>{ '', '', '' },
        1 => new List<String>{ 'тысяча', 'тысячи', 'тысяч' },
        2 => new List<String>{ 'миллион', 'миллиона', 'миллионов' },
        3 => new List<String>{ 'миллиард', 'миллиарда', 'миллиардов' }
    };
    public static final String ZERO = 'ноль';
    public static final String TEN_DIGIT_POSTFIX = 'десят';
    public static final String HUNDRED_DIGIT_POSTFIX = 'ста';
    public static final Map<RUSSIAN_CASE, String> CASE_POSTFIX_HUNDRED_MAPPING = new Map<RUSSIAN_CASE, String>{
        RUSSIAN_CASE.GENITIVE => 'сот',
        RUSSIAN_CASE.DATIVE => 'стам',
        RUSSIAN_CASE.INSTRUMENTAL => 'стами',
        RUSSIAN_CASE.PREPOSITIONAL => 'стах'
    };
    public static final Map<RUSSIAN_CASE, String> CASE_POSTFIX_MAPPING = new Map<RUSSIAN_CASE, String>{
        RUSSIAN_CASE.NOMINATIVE => 'ь',
        RUSSIAN_CASE.GENITIVE => 'и',
        RUSSIAN_CASE.DATIVE => 'и',
        RUSSIAN_CASE.ACCUSATIVE => 'ь',
        RUSSIAN_CASE.INSTRUMENTAL => 'ью',
        RUSSIAN_CASE.PREPOSITIONAL => 'и'
    };
    public static final Map<Integer, Map<RUSSIAN_CASE, String>> CASE_POSTFIX_MAPPING_ONE = new Map<Integer, Map<RUSSIAN_CASE, String>>{
        0 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'ин',
            RUSSIAN_CASE.GENITIVE => 'ного',
            RUSSIAN_CASE.DATIVE => 'ному',
            RUSSIAN_CASE.ACCUSATIVE => 'ин',
            RUSSIAN_CASE.INSTRUMENTAL => 'ним',
            RUSSIAN_CASE.PREPOSITIONAL => 'ном'
        },
        1 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'на',
            RUSSIAN_CASE.GENITIVE => 'ной',
            RUSSIAN_CASE.DATIVE => 'ной',
            RUSSIAN_CASE.ACCUSATIVE => 'ну',
            RUSSIAN_CASE.INSTRUMENTAL => 'ной',
            RUSSIAN_CASE.PREPOSITIONAL => 'ной'
        }
    };
    public static final Map<Integer, Map<RUSSIAN_CASE, String>> CASE_POSTFIX_MAPPING_TWO = new Map<Integer, Map<RUSSIAN_CASE, String>>{
        0 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'а',
            RUSSIAN_CASE.GENITIVE => 'ух',
            RUSSIAN_CASE.DATIVE => 'ум',
            RUSSIAN_CASE.ACCUSATIVE => 'а',
            RUSSIAN_CASE.INSTRUMENTAL => 'умя',
            RUSSIAN_CASE.PREPOSITIONAL => 'ух'
        },
        1 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'е',
            RUSSIAN_CASE.GENITIVE => 'ух',
            RUSSIAN_CASE.DATIVE => 'ум',
            RUSSIAN_CASE.ACCUSATIVE => 'е',
            RUSSIAN_CASE.INSTRUMENTAL => 'умя',
            RUSSIAN_CASE.PREPOSITIONAL => 'ух'
        }
    };
    public static final Map<Integer, Map<RUSSIAN_CASE, String>> CASE_POSTFIX_MAPPING_EXCEPTIONS = new Map<Integer, Map<RUSSIAN_CASE, String>>{
        0 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'ь',
            RUSSIAN_CASE.GENITIVE => 'я',
            RUSSIAN_CASE.DATIVE => 'ю',
            RUSSIAN_CASE.ACCUSATIVE => 'ь',
            RUSSIAN_CASE.INSTRUMENTAL => 'ём',
            RUSSIAN_CASE.PREPOSITIONAL => 'е'
        },
        3 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'и',
            RUSSIAN_CASE.GENITIVE => 'ёх',
            RUSSIAN_CASE.DATIVE => 'ём',
            RUSSIAN_CASE.ACCUSATIVE => 'и',
            RUSSIAN_CASE.INSTRUMENTAL => 'емя',
            RUSSIAN_CASE.PREPOSITIONAL => 'ёх'
        },
        4 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'е',
            RUSSIAN_CASE.GENITIVE => 'ёх',
            RUSSIAN_CASE.DATIVE => 'ём',
            RUSSIAN_CASE.ACCUSATIVE => 'е',
            RUSSIAN_CASE.INSTRUMENTAL => 'ьмя',
            RUSSIAN_CASE.PREPOSITIONAL => 'ёх'
        }, 
        40 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => '',
            RUSSIAN_CASE.GENITIVE => 'а',
            RUSSIAN_CASE.DATIVE => 'а',
            RUSSIAN_CASE.ACCUSATIVE => '',
            RUSSIAN_CASE.INSTRUMENTAL => 'а',
            RUSSIAN_CASE.PREPOSITIONAL => 'а'
        },
        90 => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'о',
            RUSSIAN_CASE.GENITIVE => 'а',
            RUSSIAN_CASE.DATIVE => 'а',
            RUSSIAN_CASE.ACCUSATIVE => 'о',
            RUSSIAN_CASE.INSTRUMENTAL => 'а',
            RUSSIAN_CASE.PREPOSITIONAL => 'а'
        }
    };
    public static final Map<String, Map<RUSSIAN_CASE, String>> THOUSAND_CASE_POSTFIXES = new Map<String, Map<RUSSIAN_CASE, String>>{
        'тысяча' => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'а',
            RUSSIAN_CASE.GENITIVE => 'и',
            RUSSIAN_CASE.DATIVE => 'е',
            RUSSIAN_CASE.ACCUSATIVE => 'у',
            RUSSIAN_CASE.INSTRUMENTAL => 'ей',
            RUSSIAN_CASE.PREPOSITIONAL => 'е'
        },
        'тысячи' => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'и',
            RUSSIAN_CASE.GENITIVE => '',
            RUSSIAN_CASE.DATIVE => 'ам',
            RUSSIAN_CASE.ACCUSATIVE => 'и',
            RUSSIAN_CASE.INSTRUMENTAL => 'ами',
            RUSSIAN_CASE.PREPOSITIONAL => 'ах'
        },
        'тысяч' => new Map<RUSSIAN_CASE, String>{
            RUSSIAN_CASE.NOMINATIVE => 'ч',
            RUSSIAN_CASE.GENITIVE => 'ч',
            RUSSIAN_CASE.DATIVE => 'чам',
            RUSSIAN_CASE.ACCUSATIVE => '',
            RUSSIAN_CASE.INSTRUMENTAL => 'чами',
            RUSSIAN_CASE.PREPOSITIONAL => 'чах'
        }
    };
}
