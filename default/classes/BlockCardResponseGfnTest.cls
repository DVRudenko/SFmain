@isTest
public class BlockCardResponseGfnTest {
    @isTest
    static void test() {
        BlockCardResponseGfn blockCardResponse = new BlockCardResponseGfn();
        System.assert(blockCardResponse != null);
        System.assert(blockCardResponse.BlockRequests == null);

        BlockCardResponseGfn.BlockRequests blockRequests = new BlockCardResponseGfn.BlockRequests();
        System.assert(blockRequests != null);
        System.assert(blockRequests.CardID == null);
        System.assert(blockRequests.BlockRequested == null);
        System.assert(blockRequests.Error == null);
    }
}