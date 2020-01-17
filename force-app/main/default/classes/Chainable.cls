/* Author: Charlie Jonas (charlie@callawaycloudconsulting.com)
 *  Description: A frame work that allows Queuable contexts to linked together as syncronous opporations
*/
public class Chainable implements Queueable, Database.AllowsCallouts{

//===INSTANCE VARIABLES===

    //list of links to run
    public List<ChainableLink> chainLinks;

    public Id key {get; private set;}

    public ChainableLink currentLink {get; private set;}

    public List<ChainableLink> processedLinks {
        get {
            List<ChainableLink> processedLinks = new List<ChainableLink>();
            for(Integer i = 0; i  < position; i++){
                processedLinks.add(chainLinks[i]);
            }
            return processedLinks;
        }
    }

    //the current position in the chain
    @TestVisible Integer position;

//=== CONSTRUCTORS ===

    /* public constructor
    *  @param chainLinks: list of ChainableLink which define the work that will be done in this chain
    */
    public Chainable(List<ChainableLink> chainLinks){
        this(chainLinks, 0);
        createChainLinksRecords(0, chainLinks);
    }

    //private constructor for re-enqueue
    @TestVisible Chainable(List<ChainableLink> chainLinks, Integer position) {
        System.debug('Processing ' + chainLinks.size() + ' links from position ' + position);
        this.chainLinks = chainLinks;
        this.position = position;

        if(chainLinks != null && chainLinks.size() > 0){
            this.currentLink = chainLinks[this.position];
        }

        if(this.key == null){
            //reinstates the key if this is a chained context
            if(currentLink != null && String.isNotEmpty(currentLink.key)){
                this.key = currentLink.key;
            }else{
                Chainable_Job__c job = new Chainable_Job__c(
                name = DateTime.now() + ':' + chainLinks.size()
            );
            insert job;
            this.key = job.Id;
            }
        }
    }

// ===PUBLIC METHODS===

    /**
      * @description gets the current link in the chain
      * @return the current link that is being processed
      */
    public ChainableLink getCurrentLink(){
        return chainLinks.get(position);
    }

    /**
      * @description Logic to enqueue chain.  Checks limits and enqueues in future if possible
      */
    public void enqueue(){
        if(this.currentLink == null){
            return;
        }
        System.debug('Trying to Enqueue: ' + this.key);
        System.debug(Limits.getQueueableJobs() + '/' + Limits.getLimitQueueableJobs() + ' Queueable.');
        Boolean canEnqueue = Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
        if(canEnqueue){
            System.debug('-- Syncronous Enqueue');
            System.enqueueJob(this);
        }else if(!System.isFuture() && !System.isBatch()){
            System.debug('-- Future Enqueue');
            Chainable.enqueueFuture(this.key, position);
        }else{
            System.debug('-- Delayed Enqueue');
            //update current link so we know it should be caught by the cleanup schedulable
            update new Chainable_Link__c(Id = currentLink.recordId, Postponed__c = true);
        }
    }

    /* Runs the chainable.  Will run a new `Queueable` execution context for each ChainableLink passed in
    *  @param   context: injected by salesforce
    */
    public void execute(QueueableContext context){
        System.debug('Postion: ' + position);
        //get the next link that is set to run
        while(currentLink.skipProcessing){
            position++;

            //exit if no more chainLinks to look at
            if(position == chainLinks.size()){
                return;
            }

            currentLink = chainLinks[position];
        }

        initLinkRecords(context.getJobId());

        //setup rollbacks
        System.SavePoint sp;
        if(currentLink.rollbackOnException){
            sp = Database.setSavepoint();
        }

        try{
            IChainableAction action = currentLink.getAction();

            //execute action
            Object result = action.execute(this);
            if(result != null){
                currentLink.response = JSON.serialize(result);
            }

            if(position == chainLinks.size()-1){
                currentLink.exited = true;
            }
            currentLink.error = null;
        }catch(Exception e){

            if(sp != null){
                Database.rollback(sp);
            }
            currentLink.error = (e.getMessage() + '\n ' + e.getStackTraceString()).left(131071);
            if(!currentLink.continueOnException || position == chainLinks.size()-1){
                currentLink.exited = true;
            }
        }
        //save record
        Chainable_Link_Execution__c execRecord = currentLink.createExecutionRecord();
        insert execRecord;
        update new Chainable_Link__c(
            Id = currentLink.recordId,
            Last_Execution__c = execRecord.Id,
            Last_Link__c = currentLink.exited,
            Postponed__c = false
        );

        //re-enqueue
        if(position < chainLinks.size()-1){
            if(currentLink.error == null || currentLink.continueOnException){
                //run next link
                if(Test.isRunningTest()){
                    this.position++;
					this.currentLink = chainLinks[position];
                    this.execute(context);
                }else{
                	enqueueFuture(this.key, this.position+1);
                }

            }
        }
    }

    /**
      * @description Allows appending of additional links to the end of the chain.
      * @param chainLinks
      * @example
      */
    public void appendLinks(List<ChainableLink> newChainLinks){
        Integer nextPos = chainLinks.size();
        createChainLinksRecords(nextPos, newChainLinks);
        this.chainLinks.addAll(newChainLinks);
    }

//=== PRIVATE METHODS ===
    // Sets the job Id and data when executing links.
    // Also intializes all link records when first run.
    private void initLinkRecords(String jobId){
        //set job Id for each execution
        ChainableLink currentAc = chainLinks[position];
        currentAc.jobId = jobId;
        currentAc.executedDate = Datetime.now();

    }

    private void createChainLinksRecords(Integer startPos, List<ChainableLink> links){

        List<Chainable_Link__c> records = new List<Chainable_Link__c>();

        ChainableLink parent;
        for(Integer i = 0; i < links.size(); i++){
            //setup parent links
            ChainableLink ac = links[i];
            if(parent == null){
                parent = ac;
            }else{
                ac.parent = parent;
                parent = ac;
            }

            ac.key = this.key;
            ac.position = startPos + i;
            records.add(ac.createLinkRecord(this.key));
        }
        insert records;
        //set recordIds on links
        for(Integer i = 0; i < records.size(); i++){
            links[i].recordId = records[i].Id;
        }
    }

//== STATICS ==

    /* Runs the chain again.
    *  @param   key: The key of the chain
    *  @param   position: where to start execution on the chain
    *  @param   failuresOnly: will only reprocess links that failed
    *  @return  A chainable that is ready to enqueue
    */
    public static Chainable reprocessChain(Id key, Integer position, Boolean failuresOnly){
        Chainable_Link__c[] linksToReprocess = new Chainable_Link__c[]{};
        ChainableLink[] chainLinks = new ChainableLink[]{};
        Chainable_Link__c[] prevLinks = queryChainRecords(key);
        for(Integer i = 0; i < prevLinks.size(); i++){
            Chainable_Link__c linkRecord = prevLinks[i];
            if(i >= position
                && (!failuresOnly || (failuresOnly && linkRecord.Last_Execution__r.Error__c != null) || linkRecord.Last_Execution__r == null)){
                linkRecord.Last_Execution__r = null;
                linkRecord.Last_Execution__c = null;
                linksToReprocess.add(linkRecord);
            }
            chainLinks.add(new ChainableLink(linkRecord));
        }

        update linksToReprocess;

        Chainable chainable = new Chainable(chainLinks, position);
        return chainable;
    }

    public static Chainable restoreChain(Id key, Integer position){
        ChainableLink[] chainLinks = loadChainLink(key);
        return new Chainable(chainLinks, position);
    }

    @future
    private static void enqueueFuture(String key, Integer position){
        //was previously seralizing the chainable object
        //  but that caused issues with really large chains.
        //  Using the future context to "Rebuild" the chain allow this to scale
        System.enqueueJob(restoreChain(key, position));
    }

    //used to reload the records as Chain Links
    @TestVisible static List<ChainableLink> loadChainLink(Id key){
        List<ChainableLink> chainLinks = new List<ChainableLink>();
        ChainableLink parent;
        for(Chainable_Link__c linkRecord : queryChainRecords(key)){
            ChainableLink link = new ChainableLink(linkRecord);
            link.parent = parent;
            chainLinks.add(link);
            parent = link;
        }
        return chainLinks;
    }

    //query records
    private static List<Chainable_Link__c> queryChainRecords(Id key){
        return [SELECT Name, Chainable_Job__c,
                        Link_Position__c,
                        Response_Type__c, Action_Data__c,
                        Action_Type__c, Last_Execution__c, Last_Execution__r.Error__c,
                        Last_Execution__r.Response__c, Last_Execution__r.Executed_Date__c,
                        Last_Link__c, Continue_on_Exception__c,
                        Rollback_on_Exception__c
                        FROM Chainable_Link__c WHERE Chainable_Job__c = :key
                        ORDER BY Link_Position__c ASC];
    }

    //generates a unique string to use as the chain "key"
    private static String generateGuid(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }

    public class ChainableException extends Exception{}
}
