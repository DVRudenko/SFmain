public class RefreshMetrics {
  private static final String INSTANCE = URL.getSalesforceBaseUrl().toExternalForm(); // NOTE: replace with your salesforce instance

   // Refreshes metrics which aren't overdue for the specified goalId. If the goalId is null, all non-overdue metrics are refreshed
   public static void refreshMetrics(Set<Id> goalsSets) {    
        // Date today = DateTime.now().dateGMT(); // optionally can use GMT date  
        Date today = Date.today();
        String sessionId = Userinfo.getSessionId();
        Id userId = Userinfo.getUserId();
        System.debug('Session id: ' + sessionId);
        System.debug('User id: ' + userId);       
        System.debug('today: ' + today);

        // Get metric data links
        Set<Id> keys = new Set<Id>();
        for (MetricDataLink link : [select targetId from MetricDataLink]) {
            keys.add(link.targetId);
        }

        // Get metrics to refresh
        List<Metric> metrics = null;
        if (goalsSets == null) {
            metrics = [select id from Metric where (dueDate >= :today or dueDate = null) and id in :keys];
        } else {
            // metrics = [select id from Metric where goalId = :goalId and (dueDate >= :today or dueDate = null) and id in :keys]; 
            System.debug('DEBUG: goalsSets  === ' + goalsSets);
            System.debug('DEBUG: keys  === ' + keys);
            metrics = [select id from Metric where goalId IN :goalsSets and id in :keys]; 
        }

        // refresh metrics
        for (Metric metric : metrics) {
            refreshMetric(metric.id, sessionId, userId);
        }
    }  

    //@future (callout=true) // NOTE asynchronous http callout required in scheduled jobs
    public static void refreshMetric(Id metricId, String sessionId, Id userId) {
        System.debug('Processing metric: ' + metricId);
        System.debug('Session id: ' + sessionId);
        System.debug('User id: ' + userId);       

        HttpRequest req = new HttpRequest();
        String url = INSTANCE + '/services/data/v33.0/actions/standard/metricRefresh';
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        req.setHeader('Force-Instance-Url', INSTANCE); 
        req.setHeader('Force-User-Id', userId);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"inputs":[{"metricId":"' + metricId + '"}]}'); // metric id

        Http http = new Http();
        if  ( ! Test.isRunningTest() ) {
            HTTPResponse res = http.send(req);
        }
    }
}