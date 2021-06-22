@isTest
private class LeadRelocationScheduleTest {
    @isTest
    public static void relTest() {
		LeadRelocationSchedule l = new LeadRelocationSchedule();
		//String sch = '0 0,10,20,30,40,50 8-18 * * W';
		String sch = '0 10 8-20 ? * MON-FRI';
		System.schedule('Lead Relocation', sch, l);
    }
}