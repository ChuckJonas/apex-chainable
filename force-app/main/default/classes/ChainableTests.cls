/**
 * Unforuntely Salesforce only allows us to execute a single queueable in a test...
 * This makes it difficult to test
 */
@istest
private class ChainableTests {
    @isTest
    private static void testInit() {
        ChainableLink[] links = ChainTestingActions.createTelephoneChain('One Two');

        Chainable chain = new Chainable(links);
        Test.startTest();
        System.enqueueJob(chain);
        Test.stopTest();

        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(2, recordLinks.size());

        System.assertEquals(
            'One ',
            ((ChainTestingActions.TelephoneResponse) JSON.deserialize(
                    recordLinks[0].Last_Execution__r.Response__c,
                    ChainTestingActions.TelephoneResponse.class
                ))
                .message
        );
        System.assertEquals(chain.key, recordLinks[0].Chainable_Job__c);
        System.assertEquals(chain.key, recordLinks[1].Chainable_Job__c);

        links = Chainable.loadChainLink(chain.key);

        System.assertEquals(2, links.size());
        System.assertEquals(
            'One ',
            ((ChainTestingActions.TelephoneResponse) JSON.deserialize(
                    recordLinks[0].Last_Execution__r.Response__c,
                    ChainTestingActions.TelephoneResponse.class
                ))
                .message
        );
        System.assertEquals(links[0], links[1].parent);
        chain = new Chainable(links, chain.position + 1, null);

        System.assertEquals(links[1], chain.currentLink);
    }

    @isTest
    private static void testFinal() {
        ChainableLink[] links = ChainTestingActions.createTelephoneChain('One');

        Chainable chain = new Chainable(links);
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(1, recordLinks.size());

        System.assertEquals(null, recordLinks[0].Last_Execution__r.Error__c);
        System.assertEquals(
            'One ',
            ((ChainTestingActions.TelephoneResponse) JSON.deserialize(
                    recordLinks[0].Last_Execution__r.Response__c,
                    ChainTestingActions.TelephoneResponse.class
                ))
                .message
        );
        System.assertEquals(chain.key, recordLinks[0].Chainable_Job__c);
        System.assertNotEquals(null, recordLinks[0].Last_Execution__r.Job_Id__c);
        System.assertEquals(true, recordLinks[0].Last_Link__c);
    }

    @isTest
    private static void testContinueOnException() {
        ChainableLink[] links = new List<ChainableLink>();
        ChainableLink link = new ChainableLink(new ChainTestingActions.ExceptionAction('abc'));
        link.continueOnException = true;
        links.add(link);
        ChainableLink link2 = new ChainableLink(new ChainTestingActions.ExceptionAction('abc'));
        link2.continueOnException = false;
        links.add(link2);

        //3rd link will not run
        links.add(new ChainableLink(new ChainTestingActions.ExceptionAction('abc')));

        Chainable chain = new Chainable(links);
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.debug(recordLinks);
        System.assertNotEquals(null, recordLinks[0].Last_Execution__r.Error__c);
        System.assertEquals(false, recordLinks[0].Success__c);
        System.assertNotEquals(null, recordLinks[1].Last_Execution__c);
        System.assertEquals(null, recordLinks[2].Last_Execution__c);
    }

    @isTest
    private static void testBreakOnException() {
        ChainableLink[] links = new List<ChainableLink>();
        ChainableLink link = new ChainableLink(new ChainTestingActions.ExceptionAction('abc'));
        link.continueOnException = false;
        links.add(link);
        links.add(new ChainableLink(new ChainTestingActions.ExceptionAction('abc')));

        Chainable chain = new Chainable(links);
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertNotEquals(null, recordLinks[0].Last_Execution__r.Error__c);
        System.assertEquals(false, recordLinks[0].Success__c);
        System.assertEquals(null, recordLinks[1].Last_Execution__c);
    }

    @isTest
    private static void testRollbackOnException() {
        ChainableLink[] links = new List<ChainableLink>();
        ChainableLink link = new ChainableLink(new ChainTestingActions.ExceptionAction('abc'));
        link.rollbackOnException = true;
        links.add(link);

        Chainable chain = new Chainable(links);
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        List<Account> accs = [SELECT Id FROM Account WHERE Name = 'abc'];
        System.assertEquals(0, accs.size());
    }

    @isTest
    private static void testNoRollbackOnException() {
        ChainableLink[] links = new List<ChainableLink>();
        ChainableLink link = new ChainableLink(new ChainTestingActions.ExceptionAction('abc'));
        link.rollbackOnException = false;
        links.add(link);

        Chainable chain = new Chainable(links);
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        List<Case> accs = [SELECT Id FROM Case WHERE Subject = 'abc'];
        System.assertEquals(1, accs.size());
    }

    @isTest
    private static void testReprocessChainFromBeginning() {
        ChainableLink[] links = ChainTestingActions.createTelephoneChain('One Two');

        Chainable chain = new Chainable(links);

        //setup first link as if it has been processed
        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(2, recordLinks.size());
        Chainable_Link_Execution__c exec = new Chainable_Link_Execution__c(
            Job_Id__c = 'a1',
            Chainable_Link__c = recordLinks[0].Id,
            Response__c = JSON.serialize(new ChainTestingActions.TelephoneResponse('One '))
        );
        insert exec;
        recordLinks[0].Last_Execution__c = exec.Id;
        update recordLinks[0];

        chain = Chainable.reprocessChain(chain.key, 0, false);
        recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(1, [SELECT Id FROM Chainable_Job__c].size());
        for (Chainable_Link__c linkRecord : recordLinks) {
            System.assertEquals(null, linkRecord.Last_Execution__c);
            System.assertEquals(false, linkRecord.Success__c);
            System.assertEquals(false, linkRecord.Processed__c);
        }
        System.assertEquals(2, recordLinks.size());
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(null, recordLinks[1].Last_Execution__r.Error__c);
        System.assertEquals(true, recordLinks[0].Success__c);
        System.assertEquals(true, recordLinks[1].Last_Link__c);
        System.assertEquals(
            'One Two ',
            ((ChainTestingActions.TelephoneResponse) JSON.deserialize(
                    recordLinks[1].Last_Execution__r.Response__c,
                    ChainTestingActions.TelephoneResponse.class
                ))
                .message
        );
    }

    @isTest
    private static void testReprocessChainFromMid() {
        ChainableLink[] links = ChainTestingActions.createTelephoneChain('One Two');

        Chainable chain = new Chainable(links);

        //setup first link as if it has been processed
        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(2, recordLinks.size());
        Chainable_Link_Execution__c exec = new Chainable_Link_Execution__c(
            Job_Id__c = 'a1',
            Chainable_Link__c = recordLinks[0].Id,
            Response__c = JSON.serialize(new ChainTestingActions.TelephoneResponse('One '))
        );
        insert exec;
        recordLinks[0].Last_Execution__c = exec.Id;
        update recordLinks[0];

        chain = Chainable.reprocessChain(chain.key, 1, false);
        recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(2, recordLinks.size());
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(null, recordLinks[1].Last_Execution__r.Error__c);
        System.assertEquals(true, recordLinks[1].Last_Link__c);
        System.assertEquals(
            'One Two ',
            ((ChainTestingActions.TelephoneResponse) JSON.deserialize(
                    recordLinks[1].Last_Execution__r.Response__c,
                    ChainTestingActions.TelephoneResponse.class
                ))
                .message
        );
    }

    @isTest
    private static void testReprocessChainFailuresOnly() {
        ChainableLink[] links = ChainTestingActions.createTelephoneChain('One Two Three');

        Chainable chain = new Chainable(links);

        Datetime firstExecutionDate = DateTime.now();

        //setup first link as if it has been processed
        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(3, recordLinks.size());
        Chainable_Link_Execution__c exec1 = new Chainable_Link_Execution__c(
            Job_Id__c = 'a1',
            Chainable_Link__c = recordLinks[0].Id,
            Response__c = JSON.serialize(new ChainTestingActions.TelephoneResponse('One ')),
            Executed_Date__c = firstExecutionDate
        );

        Chainable_Link_Execution__c exec2 = new Chainable_Link_Execution__c(
            Job_Id__c = 'a2',
            Chainable_Link__c = recordLinks[1].Id,
            Error__c = 'FAILED!'
        );

        insert new List<Chainable_Link_Execution__c>{ exec1, exec2 };

        recordLinks[0].Last_Execution__c = exec1.Id;
        recordLinks[1].Last_Execution__c = exec2.Id;
        update new List<Chainable_Link__c>{ recordLinks[0], recordLinks[1] };

        chain = Chainable.reprocessChain(chain.key, 0, true);
        recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(3, recordLinks.size());
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(firstExecutionDate, recordLinks[0].Last_Execution__r.Executed_Date__c);
        System.assertEquals(null, recordLinks[1].Last_Execution__r.Error__c);
        System.assertEquals(true, recordLinks[2].Last_Link__c);
        System.assertEquals(
            'One Two Three ',
            ((ChainTestingActions.TelephoneResponse) JSON.deserialize(
                    recordLinks[2].Last_Execution__r.Response__c,
                    ChainTestingActions.TelephoneResponse.class
                ))
                .message
        );
    }

    @isTest
    private static void testAppendLinks() {
        ChainableLink link = new ChainableLink(new ChainTestingActions.AppendAction('two three'));

        Chainable chain = new Chainable(new List<ChainableLink>{ link });
        Test.startTest();
        chain.enqueue();
        Test.stopTest();

        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(3, recordLinks.size());
        System.assertEquals(false, recordLinks[0].Last_Link__c);
    }

    @isTest
    private static void testCleanup() {
        ChainableLink[] links = ChainTestingActions.createTelephoneChain('One');

        Chainable chain = new Chainable(links);
        update new Chainable_Link__c(Id = links[0].recordId, Postponed__c = true);
        Test.startTest();
        ChainableCleanupSchedulable cleanup = new ChainableCleanupSchedulable();
        cleanup.execute(null);
        Test.stopTest();

        List<Chainable_Link__c> recordLinks = ChainableVFSupport.getJobStatus(chain.key);
        System.assertEquals(1, recordLinks.size());

        System.assertEquals(false, recordLinks[0].Postponed__c);
        System.assertEquals(null, recordLinks[0].Last_Execution__r.Error__c);
        System.assertEquals(
            'One ',
            ((ChainTestingActions.TelephoneResponse) JSON.deserialize(
                    recordLinks[0].Last_Execution__r.Response__c,
                    ChainTestingActions.TelephoneResponse.class
                ))
                .message
        );
        System.assertEquals(chain.key, recordLinks[0].Chainable_Job__c);
        System.assertEquals(true, recordLinks[0].Last_Link__c);
    }
}
