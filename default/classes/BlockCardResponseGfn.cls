global class BlockCardResponseGfn {

    public List<BlockRequests> BlockRequests { get; private set; }

    public class BlockRequests {
        public Integer CardID { get; private set; }
        public Boolean BlockRequested { get; private set; }
        public String Error { get; private set; }
    }
}