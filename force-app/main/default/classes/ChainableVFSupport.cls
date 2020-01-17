/* Author: Charlie Jonas (charlie@callawaycloudconsulting.com)
 *  Description: Remote Action support for client side event emitter library (ChainableHandler.resource)
 */
global class ChainableVFSupport {
    public ChainableVFSupport(ApexPages.StandardController stdController) {
    }

    @RemoteAction
    global static List<Chainable_Link__c> getJobStatus(Id key) {
        List<Chainable_Link__c> links = [
            SELECT
                Id,
                Name,
                Chainable_Job__c,
                Action_Type__c,
                Success__c,
                Processed__c,
                Postponed__c,
                Last_Execution__c,
                Last_Execution__r.Error__c,
                Last_Execution__r.Job_Id__c,
                Last_Execution__r.Response__c,
                Last_Execution__r.Executed_Date__c,
                Response_Type__c,
                Link_Position__c,
                Last_Link__c,
                CreatedDate
            FROM Chainable_Link__c
            WHERE Chainable_Job__c = :key
            ORDER BY Link_Position__c ASC
        ];
        return links;
    }
}
