global class E2EFormsFirstPushScheduler implements Schedulable {

	/*******************************************************************************
	*  Name            : E2EFormsFirstPushScheduler()
	*  Summary         : constructor    
	*  CreatedDate     : 02/11/2018
	*  ModifiedDate    : -
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public E2EFormsFirstPushScheduler() {}


	/*******************************************************************************
    *  Name            : execute(Schedulable sc)
    *  Summary         : execute batch for sending request to E2E Form  
    *  CreatedDate     : 02/11/2018
    *  Parameters      : Schedulable sc - object to track the schedulable job
    *  Returns         : void
    ******************************************************************************/
    global void execute(SchedulableContext sc) {
    	try {
            for (String endPoint :endpointsSet) {
                sendRequestToE2E(endPoint);
            }
	        deleteExecutedJobs();
        } catch (Exception e) {} 
    }

    /*******************************************************************************
    *  Name            : sendRequestToE2E(siteUrl)
    *  Summary         : send request to E2E forms (desktop and mobile versions)    
    *  CreatedDate     : 02/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String siteUrl
    *  Returns         : void
    ******************************************************************************/
    @future(callout = true)
	public static void sendRequestToE2E(String siteUrl) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(siteUrl);
            request.setMethod('GET');
            request.setCompressed(true);
            request.setTimeout(120000);
            Http protocol = new Http();
            protocol.send(request);
        } catch (Exception e) {}
    }


    /*******************************************************************************
    *  Name            : deleteExecutedJobs()
    *  Summary         : delete scheduled jobs that already executed
    *  CreatedDate     : 02/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void deleteExecutedJobs() {
    	List<CronTrigger> jobsList = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE 'E2E Forms First Push%' AND PreviousFireTime != null
                LIMIT 100
        ];
        if ( ! jobsList.isEmpty()) {
            for (CronTrigger job : jobsList) {
                System.abortJob(job.Id);
            }
        }

        String sch = Datetime.now().addMinutes(5).second() + ' ' + Datetime.now().addMinutes(5).minute() + ' *' + ' ?' + ' *' + ' *';
        E2EFormsFirstPushScheduler scheduleE2EformsFirstPush = new E2EFormsFirstPushScheduler();
        System.schedule('E2E Forms First Push' + ' ' + Datetime.now().addMinutes(5) + '(' + Math.random() + ')', sch, scheduleE2EformsFirstPush);
    }


    private static final Set<String> endpointsSet = new Set<String> {
        'https://online.fleetcor.de/e2eform?country=Germany&utm_source=testjob',
        'https://online.fleetcor.de/e2eformmob?country=Germany&utm_source=testjob',
        'https://online.fleetcor.nl/e2eformnl?utm_source=testjob',
        'https://online.fleetcor.nl/e2eformmobnl?utm_source=testjob',
        'https://online.fleetcorcards.be/e2eformbenl?utm_source=testjob',
        'https://online.fleetcorcards.be/e2eformmobbenl?utm_source=testjob',
        'https://online.fleetcorcards.be/e2eformbefr?utm_source=testjob',
        'https://online.fleetcorcards.be/e2eformmobbefr?utm_source=testjob',
        'https://online.fleetcor.pl/e2eformpl?utm_source=testjob',
        'https://online.fleetcor.pl/e2eformmobpl?utm_source=testjob',
        'https://online.fleetcor.hu/e2eformhu?utm_source=testjob',
        'https://online.fleetcor.hu/e2eformmobhu?utm_source=testjob'
    };
}