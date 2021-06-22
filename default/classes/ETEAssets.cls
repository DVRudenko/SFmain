public with sharing class ETEAssets {
    private final static String PREFIX_SOURCE = 'build_';
    private final static String ASSETS_SOURCE_FILE_PATH = '/assets.json';
    private final static String INDEX_CHUNK = 'index';
    public List<ChunkData> preloadChunks {get;set;}
    public ChunkData indexChunk {get;set;}
    public ChunkData defaultChunk {get;set;}
    public String indexCss {get;set;}
    public String indexJs {get;set;}
    public ETEAssets (String implKey, List<String> steps, String defaultStep) {
        String buildType = ETEGlobalUtils.returnBuildTypeByImplKey(implKey);
        String source = PREFIX_SOURCE + buildType;
        String staticData = '{"index": {"js":"jsTest", "css":"testCss"}, "contacts": {"js":"jsTest", "css":"testCss"}}';
        if (! Test.isRunningTest()) {
            staticData = PageReference.forResource(source, ASSETS_SOURCE_FILE_PATH).getContent().toString();
        }
        Map<String,ChunkData> assets = (Map<String,ChunkData>)JSON.deserialize(staticData, Map<String,ChunkData>.class);
        this.preloadChunks =  getPreloadScripts(assets, steps, defaultStep);
        this.defaultChunk = assets.get(defaultStep);
        this.indexChunk = assets.get(INDEX_CHUNK);
        this.indexCss = '';
        this.indexJs = '';
        if (! Test.isRunningTest()) {
            this.indexCss = PageReference.forResource(source, indexChunk.css.replace('/resource/' + source,'')).getContent().toString();
            this.indexJs = PageReference.forResource(source, indexChunk.js.replace('/resource/' + source,'')).getContent().toString();
        }
    }
    public List<ChunkData> getPreloadScripts (Map<String,ChunkData> assets, List<String> steps,  String defaultStep) {
        List<ChunkData> result = new List<ChunkData>{
                new ChunkData('/jslibrary/1607407272232/sfdc/NetworkTracking.js'),
                new ChunkData('/static/111213/js/perf/stub.js')
        };
        for (String chunkKey : assets.keySet()) {
            if(chunkKey != INDEX_CHUNK && steps.contains(chunkKey) && chunkKey != defaultStep){
                result.add(assets.get(chunkKey));
            }
        }
        return result;
    }
    private class ChunkData {
        public String js {get;set;}
        public String css {get;set;}
        public ChunkData (String js) {
            this.js = js;
        }
    }
}