/**
 * Created by Nikita.Mikhailov on 30.01.2019.
 */

public class CustomPagination {

    public static Boolean hasNext(Integer currentPageNumber, Integer pageSize, Integer totalSize) {
        if (currentPageNumber * pageSize < totalSize)
            return true;

        return false;
    }

    public static Boolean hasPrevious(Integer currentPageNumber, Integer pageSize) {
        if ((currentPageNumber - 1) * pageSize > 0)
            return true;

        return false;
    }

    public static List<Object> first(List<Object> inputList, Integer pageSize) {

        List<Object> page = new List<Object>();

        for (Integer i = 0; i < pageSize && i < inputList.size(); i++) {
            page.add(inputList.get(i));
        }

        return page;
    }

    public static List<Object> next(List<Object> inputList, Integer nextPageNumber, Integer pageSize) {

        List<Object> page = new List<Object>();

        for (Integer i = (nextPageNumber - 1) * pageSize; i < (nextPageNumber - 1) * pageSize + pageSize && i < inputList.size(); i++) {
            page.add(inputList.get(i));
        }

        return page;
    }

    public static List<Object> previous(List<Object> inputList, Integer previousPageNumber, Integer pageSize) {

        List<Object> page = new List<Object>();

        for (Integer i = (previousPageNumber - 1) * pageSize; i < (previousPageNumber - 1) * pageSize + pageSize && i >= 0; i++) {
            page.add(inputList.get(i));
        }

        return page;
    }

    public static List<Object> last(List<Object> inputList, Integer lastPageNumber, Integer pageSize) {
        List<Object> page = new List<Object>();

        for (Integer i = (lastPageNumber - 1) * pageSize; i < (lastPageNumber - 1) * pageSize + pageSize && i < inputList.size(); i++) {
            page.add(inputList.get(i));
        }

        return page;
    }
}