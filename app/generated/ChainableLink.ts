import { Rest, RestObject, SObject, sField, SalesforceFieldType, SFLocation, SFieldProperties, FieldResolver, SOQLQueryParams, buildQuery, FieldProps } from "ts-force";
import "./";

export type ChainableLinkFields = Partial<FieldProps<ChainableLink>>;

/**
 * Generated class for Chainable_Link__c
 */
export class ChainableLink extends RestObject {
    @sField({ apiName: 'Id', createable: false, updateable: false, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.ID, salesforceLabel: 'Record ID', externalId: false })
    public readonly id: string;
    @sField({ apiName: 'OwnerId', createable: true, updateable: true, required: true, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.REFERENCE, salesforceLabel: 'Owner ID', externalId: false })
    public ownerId: string;
    @sField({ apiName: 'IsDeleted', createable: false, updateable: false, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.BOOLEAN, salesforceLabel: 'Deleted', externalId: false })
    public readonly isDeleted: boolean;
    @sField({ apiName: 'Name', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.STRING, salesforceLabel: 'Job Id', externalId: false })
    public name: string;
    @sField({ apiName: 'CreatedDate', createable: false, updateable: false, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.DATETIME, salesforceLabel: 'Created Date', externalId: false })
    public readonly createdDate: Date;
    @sField({ apiName: 'CreatedById', createable: false, updateable: false, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.REFERENCE, salesforceLabel: 'Created By ID', externalId: false })
    public readonly createdById: string;
    @sField({ apiName: 'LastModifiedDate', createable: false, updateable: false, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.DATETIME, salesforceLabel: 'Last Modified Date', externalId: false })
    public readonly lastModifiedDate: Date;
    @sField({ apiName: 'LastModifiedById', createable: false, updateable: false, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.REFERENCE, salesforceLabel: 'Last Modified By ID', externalId: false })
    public readonly lastModifiedById: string;
    @sField({ apiName: 'SystemModstamp', createable: false, updateable: false, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.DATETIME, salesforceLabel: 'System Modstamp', externalId: false })
    public readonly systemModstamp: Date;
    /**
     * Actions that were not completed.  Allows chain to be restarted after an error occurs
     */
    @sField({ apiName: 'Action_Data__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.TEXTAREA, salesforceLabel: 'Action_Data', externalId: false })
    public actionData: string;
    /**
     * The type of action that was executed by this chain
     */
    @sField({ apiName: 'Action_Type__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.STRING, salesforceLabel: 'Action Type', externalId: false })
    public actionType: string;
    /**
     * Determines if this link will continue execution on an exception
     */
    @sField({ apiName: 'Continue_on_Exception__c', createable: true, updateable: true, required: true, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.BOOLEAN, salesforceLabel: 'Continue on Exception', externalId: false })
    public continueonException: boolean;
    @sField({ apiName: 'Error__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.TEXTAREA, salesforceLabel: 'Error', externalId: false })
    public error: string;
    /**
     * The date the action was executed
     */
    @sField({ apiName: 'Executed_Date__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.DATETIME, salesforceLabel: 'Exceuted Date', externalId: false })
    public executedDate: Date;
    @sField({ apiName: 'Has_Error__c', createable: true, updateable: true, required: true, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.BOOLEAN, salesforceLabel: 'Has Error', externalId: false })
    public hasError: boolean;
    /**
     * The key for this chain.  Must be unique!
     */
    @sField({ apiName: 'Key__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.STRING, salesforceLabel: 'Key', externalId: true })
    public key: string;
    /**
     * Signifies that there are no more links being processed
     */
    @sField({ apiName: 'Last_Link__c', createable: true, updateable: true, required: true, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.BOOLEAN, salesforceLabel: 'Last Link', externalId: false })
    public lastLink: boolean;
    /**
     * The position this link is in the chain. 0 based
     */
    @sField({ apiName: 'Link_Position__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.DOUBLE, salesforceLabel: 'Link Position', externalId: false })
    public linkPosition: number;
    /**
     * The type of object (serialized) stored in the response
     */
    @sField({ apiName: 'Response_Type__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.STRING, salesforceLabel: 'Response Type', externalId: false })
    public responseType: string;
    @sField({ apiName: 'Response__c', createable: true, updateable: true, required: false, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.TEXTAREA, salesforceLabel: 'Response', externalId: false })
    public response: string;
    /**
     * Determines if DML should be rolled back when an exception occurs during chain execution
     */
    @sField({ apiName: 'Rollback_on_Exception__c', createable: true, updateable: true, required: true, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.BOOLEAN, salesforceLabel: 'Rollback on Exception', externalId: false })
    public rollbackonException: boolean;
    /**
     * Don't process this row. Used for re-running failures
     */
    @sField({ apiName: 'Skip_Processing__c', createable: true, updateable: true, required: true, reference: undefined, childRelationship: false, salesforceType: SalesforceFieldType.BOOLEAN, salesforceLabel: 'Skip Processing', externalId: false })
    public skipProcessing: boolean;

    constructor(fields?: ChainableLinkFields, client?: Rest) {
        super('Chainable_Link__c', client);
        this.id = void 0;
        this.ownerId = void 0;
        this.isDeleted = void 0;
        this.name = void 0;
        this.createdDate = void 0;
        this.createdById = void 0;
        this.lastModifiedDate = void 0;
        this.lastModifiedById = void 0;
        this.systemModstamp = void 0;
        this.actionData = void 0;
        this.actionType = void 0;
        this.continueonException = void 0;
        this.error = void 0;
        this.executedDate = void 0;
        this.hasError = void 0;
        this.key = void 0;
        this.lastLink = void 0;
        this.linkPosition = void 0;
        this.responseType = void 0;
        this.response = void 0;
        this.rollbackonException = void 0;
        this.skipProcessing = void 0;
        this.initObject(fields);
        return new Proxy(this, this.safeUpdateProxyHandler);
    }

    public static API_NAME: 'Chainable_Link__c' = 'Chainable_Link__c';
    public readonly _TYPE_: 'Chainable_Link__c' = 'Chainable_Link__c';
    private static _fields: { [P in keyof FieldProps<ChainableLink>]: SFieldProperties; };

    public static get FIELDS() {
        return this._fields = this._fields ? this._fields : ChainableLink.getPropertiesMeta<FieldProps<ChainableLink>, ChainableLink>(ChainableLink)
    }

    public static async retrieve(qryParam: ((fields: FieldResolver<ChainableLink>) => SOQLQueryParams) | string): Promise<ChainableLink[]> {

        let qry = typeof qryParam === 'function' ? buildQuery(ChainableLink, qryParam) : qryParam;
        return await RestObject.query<ChainableLink>(ChainableLink, qry);

    }

    public static fromSFObject(sob: SObject): ChainableLink {
        return new ChainableLink().mapFromQuery(sob);
    }
}
