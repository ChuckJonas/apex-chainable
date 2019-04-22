//Schedulable class that cleans up any chains that could not process in realtime due to limits
global class ChainableCleanupSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
		for(Chainable_Link__c startingLink : [SELECT Key__c, Link_Position__c
                                                FROM Chainable_Link__c
                                                WHERE Name = :ChainableLink.CLEANUP_NAME
                                                LIMIT :Limits.getLimitQueueableJobs()]){
            Chainable ch = Chainable.restoreChain(startingLink.Key__c, Integer.valueOf(startingLink.Link_Position__c));
            ch.enqueue();
        }
	}
}