global class BirthdayEmailScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BirthdayEmailBatch batch = new BirthdayEmailBatch();
        Database.executeBatch(batch);
    }
}
