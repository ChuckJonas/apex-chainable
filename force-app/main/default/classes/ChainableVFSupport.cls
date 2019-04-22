/* Author: Charlie Jonas (charlie@callawaycloudconsulting.com)
 *  Description: Remote Action support for client side event emitter library (ChainableHandler.resource)
*/
global class ChainableVFSupport {

    public ChainableVFSupport(ApexPages.StandardController stdController) {}

     @RemoteAction
     global static List<Chainable_Link__c> getJobStatus(String key){
        List<Chainable_Link__c> links = [SELECT Id, Name, Action_Type__c, Key__c, Error__c,
        Response__c, Response_Type__c, Link_Position__c, Last_Link__c, Executed_Date__c, CreatedDate
                FROM Chainable_Link__c
                WHERE Key__c = :key
                ORDER BY Link_Position__c ASC];
        return links;
     }

}