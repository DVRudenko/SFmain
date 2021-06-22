public with sharing class EmarsysContactsJobService {
    public enum JobTypes {
        JOB_RUN,
        JOB_CHECK,
        JOB_CONT_RETRIEV
    }

    /*******************************************************************************
     *  Name            : scheduleJob(String jobName, Integer minute, Integer hour, JobTypes jobType)
     *  Summary         : schedule job with name at specific time on working days
     *                  : job determined by type
     *  CreatedDate     : 28/09/2020
     *  Parameters      : String jobName – name of the job,
     *                  : Integer minute – minute value for schedule,
     *                  : Integer hour - hour value for schedule,
     *                  : JobTypes jobType – type of the job, helps to determine classes to run
     *  Returns         : void
     ******************************************************************************/
    public static void scheduleJob(String jobName, Integer minute, Integer hour, JobTypes jobType) {
        List<CronTrigger> jobsList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];
        if (!jobsList.isEmpty()) {
            System.abortJob(jobsList[0].Id);
        }

        String scheduleExpression = '0 ' + minute + ' ' + hour + ' ? * MON-FRI';

        switch on jobType {
            when JOB_RUN {
                // System.schedule(jobName, scheduleExpression, class);
            }
            when JOB_CHECK {
                System.schedule(jobName, scheduleExpression, new EmarsysJobCheckerScheduler());
            }
            when JOB_CONT_RETRIEV {
                System.schedule(jobName, scheduleExpression, new EmarsysContactIdsGathererSchedule());
            }
        }
    }

    /*******************************************************************************
     *  Name            : checkIsFirstLaunch(String jobName, String firstScheduleExpression)
     *  Summary         : check job, by name and its first time run specified in the task
     *  CreatedDate     : 15/10/2020
     *  Parameters      : String jobName – name of the job,
     *                  : String firstScheduleExpression – cron expression of the first launch
     *  Returns         : Boolean, true – first time, false – not the first time launch
     ******************************************************************************/
    public static Boolean checkIsFirstLaunch(String jobName, String firstScheduleExpression) {
        List<CronTrigger> jobsList = [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];
        return (!jobsList.isEmpty() && firstScheduleExpression == jobsList[0].CronExpression);
    }
}