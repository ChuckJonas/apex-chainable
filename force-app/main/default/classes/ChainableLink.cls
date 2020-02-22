/* Author: Charlie Jonas (charlie@callawaycloudconsulting.com)
 *  Description: DTO Container to allow IChainableAction to be serialized between links
 */
public virtual class ChainableLink {
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
    public Integer immediateRetries;
    public Integer immediateAttempts;

    public Boolean completed {
        get {
            return (error == null && jobId != null);
        }
    }

    //===SERIALIZATION DATA===
    public String actionData { get; private set; }
    public String actionTypeString { get; private set; }
    private transient IChainableAction action;

    private Chainable_Link__c linkRecord;

    public ChainableLink(IChainableAction action) {
        this.action = action;
        exited = false;
        skipProcessing = false;

        immediateRetries = 0;
        immediateAttempts = 0;
        actionData = JSON.serialize(action);
        actionTypeString = action.getType().getName();
        responseType = getAction().getResponseType().getName();
    }

    //restore from link
    public ChainableLink(Chainable_Link__c record) {
        //action serialization
        actionData = record.Action_Data__c;
        actionTypeString = record.Action_Type__c;
        responseType = record.Response_Type__c;

        //control properties
        continueOnException = record.Continue_on_Exception__c;
        rollbackOnException = record.Rollback_on_Exception__c;

        //record details
        recordId = record.Id;
        key = record.Chainable_Job__c;
        position = (Integer) record.Link_Position__c;
        exited = record.Last_Link__c;

        jobId = record.Last_Execution__r.Job_Id__c;
        skipProcessing = record.Last_Execution__r != null;
        response = record.Last_Execution__r.Response__c;
        error = record.Last_Execution__r.Error__c;
        executedDate = record.Last_Execution__r.Executed_Date__c;

        immediateAttempts = (Integer) record.Immediate_Attempts__c;
        immediateRetries = (Integer) record.Immediate_Retries__c;
    }

    public virtual IChainableAction getAction() {
        if (action == null) {
            Type actionType = Type.forName(actionTypeString);
            action = (IChainableAction) JSON.deserialize(actionData, actionType);
        }
        return action;
    }

    public virtual Object getResponse() {
        if (response != null && responseType != null) {
            Type respType = Type.forName(responseType);
            return JSON.deserialize(response, respType);
        }
        return null;
    }

    public Chainable_Link__c createLinkRecord(Id jobId) {
        Chainable_Link__c linkRecord = new Chainable_Link__c(
            Id = recordId,
            Chainable_Job__c = jobId,
            Name = actionTypeString + '-' + position,
            Response_Type__c = responseType,
            Link_Position__c = position,
            Action_Data__c = actionData,
            Action_Type__c = actionTypeString,
            Continue_on_Exception__c = continueOnException,
            Rollback_on_Exception__c = rollbackOnException,
            Immediate_Attempts__c = immediateAttempts,
            Immediate_Retries__c = immediateRetries
        );

        return linkRecord;
    }

    public Chainable_Link_Execution__c createExecutionRecord() {
        return new Chainable_Link_Execution__c(
            Chainable_Link__c = recordId,
            Job_Id__c = jobId,
            Response__c = response,
            Executed_Date__c = executedDate,
            Error__c = error
        );
    }
}
