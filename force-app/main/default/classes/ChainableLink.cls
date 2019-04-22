/* Author: Charlie Jonas (charlie@callawaycloudconsulting.com)
 *  Description: DTO Container to allow IChainableAction to be serialized between links
*/
public virtual class ChainableLink{
    public static final String UNPROCESSED_NAME = '[unprocessed]';
    public static final String CLEANUP_NAME = '[cleanup]';

//===LINKING===
    public ChainableLink parent;

//===CONTROL PROPERTIES===
    //continue executing next links even if this action throws an exception. Defaulted to false
    public Boolean continueOnException = false;

    //rolls back any action DML if exception is thrown. Defaulted to true.
    //  Must be set to false if making callouts
    public Boolean rollbackOnException = true;

//===STATE PROPERTIES===
    public Id recordId;
    public String key;
    public String jobId;
    public DateTime executedDate;
    public String response;
    public String responseType;
    public Integer position;
    public String error;
    public Boolean exited;
    public Boolean skipProcessing;

    public Boolean completed {
        get {
            return (error == null && jobId != null);
        }
    }

//===SERIALIZATION DATA===
    public String actionData {get; private set;}
    public String actionTypeString {get; private set;}
    private transient IChainableAction action;

    public ChainableLink(IChainableAction action){
        this.action = action;
        exited = false;
        skipProcessing = false;

        actionData = JSON.serialize(action);
        actionTypeString = action.getType().getName();
    }

    //restore from link
    public ChainableLink(Chainable_Link__c record){
        //action serialization
        actionData = record.Action_Data__c;
        actionTypeString = record.Action_Type__c;

        //control properties
        continueOnException = record.Continue_on_Exception__c;
        rollbackOnException = record.Rollback_on_Exception__c;

        //record details
        recordId = record.Id;
        jobId = record.Name;
        key = record.Key__c;
        position = (Integer) record.Link_Position__c;
        response = record.Response__c;
        responseType = record.Response_Type__c;
        error = record.Error__c;
        exited = record.Last_Link__c;
        skipProcessing = record.Skip_Processing__c;
    }

    public virtual IChainableAction getAction(){
        if(action == null){
            Type actionType = Type.forName(actionTypeString);
            action = (IChainableAction) JSON.deserialize(actionData, actionType);
        }
        return action;
    }

    public virtual Object getResponse(){
        if(response != null && responseType != null){
            Type respType = Type.forName(responseType);
            return JSON.deserialize(actionData, respType);
        }
        return null;
    }


    public Chainable_Link__c toRecord(){
        Chainable_Link__c linkRecord = new Chainable_Link__c(
            Name = (jobId!=null ? jobId : UNPROCESSED_NAME),
            Key__c = key,
            Response__c = response,
            Response_Type__c = getAction().getResponseType().getName(),
            Link_Position__c = position,
            Error__c = error,
            Has_Error__c = !String.isEmpty(error),
            Last_Link__c = exited,
            Action_Data__c = actionData,
            Action_Type__c = actionTypeString,
            Continue_on_Exception__c = continueOnException,
            Rollback_on_Exception__c = rollbackOnException,
            Executed_Date__c = executedDate,
            Id = recordId,
            Skip_Processing__c = skipProcessing
        );
        return linkRecord;
    }
}
