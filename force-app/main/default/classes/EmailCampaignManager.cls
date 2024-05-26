public class EmailCampaignManager {
    @AuraEnabled
    public static void runBatch(String batchClassName) {
        System.debug('claas name batch: ' + batchClassName);
        Type batchType = Type.forName(batchClassName);
        if (batchType != null) {
            System.debug('batch not null (type): ' + batchType);
            Object batchInstance = batchType.newInstance();
            System.debug('batch not null (type): ' + batchInstance);
            try {
                Database.executeBatch((Database.Batchable<SObject>) batchInstance);
            } catch (Exception e) {
                System.debug('error' + e);
            }
            
        }
    }

    @AuraEnabled
    public static void scheduleBatch(String schedulerClassName, String cronString) {
        Type schedulableType = Type.forName(schedulerClassName);
        if (schedulableType != null) {
            Object schedulableInstance = schedulableType.newInstance();
            System.schedule('Birthday Email Scheduler', cronString, (Schedulable) schedulableInstance);
        }
    }

    @AuraEnabled
    public static void cancelScheduler(String schedulerClassName) {
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :schedulerClassName];
        for (CronTrigger ct : cronTriggers) {
            System.abortJob(ct.Id);
            System.System.debug('name: ' + schedulerClassName);
        }
    }
}
