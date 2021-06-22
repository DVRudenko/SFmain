/**
 * Created by Nikita.Mikhailov on 28.02.2019.
 */

@IsTest
public with sharing class CustomPaginationTest {

    @IsTest
    public static void testHasNext() {
        System.assertEquals(true, CustomPagination.hasNext(1, 20, 50));
        System.assertEquals(false, CustomPagination.hasNext(1, 20, 10));
    }

    @IsTest
    public static void testHasPrevious() {
        System.assertEquals(false, CustomPagination.hasPrevious(1, 10));
        System.assertEquals(true, CustomPagination.hasPrevious(5, 10));
    }

    @IsTest
    public static void testPagination() {
        List<String> testList = createTestList(50);
        System.assertEquals(20, CustomPagination.first(testList, 20).size());
        System.assertEquals(20, CustomPagination.next(testList, 2, 20).size());
        System.assertEquals(20, CustomPagination.previous(testList, 2, 20).size());
        System.assertEquals(10, CustomPagination.last(testList, 3, 20).size());
    }

    private static List<String> createTestList(Integer size) {
        List<String> resList = new List<String>();
        for (Integer i = 0; i < size; i++) {
            resList.add(String.valueOf(i));
        }

        return resList;
    }
}