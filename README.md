# apex-chainable
A framework for managing multiple asynchronous processes in Salesforce.  Uses Queuable to chain multiple processes together.

## Features

- Allows sequential execution multiple asyncronous actions
- Access to "Results" produced by executions further up the chain
- Fault tolerent.  Failures are tracked and chain can be reprocessed
- Custom UI to view and debug executions

## Example Use case

You need to perform multiple actions that cannot be completed in a single excution context.  Each actions is depedant on the outcome of the previous action.  If any part of the action fails, you need the ability to correct the errors (via data or metadata changes) and pick up where you left off.

## Limitations
- A `ChainAction` implemenations must be serializable!

## Best Pracices: 

- Do not seralize entire SObject and then run DML on them later. This may result in you overwriting fields with stale data.  It is best to construct/query the SObject in the action itself if you need to run DML.

## Usage

### Extend `ChainableAction`

``` apex
    //Example of how an action can read response from previous actions
    public class TelephoneAction extends ChainableAction{
        private String message;
        public TelephoneAction(String message){
            this.message = message;
        }

        public override Type getType(){
            return TelephoneAction.class;
        }

        public override Type getResponseType(){
            return TelephoneResponse.class;
        }

        public override Object execute(Chainable chain){
            //read past messages
            String s = '';
            for(ChainableLink link : chain.processedLinks){
                if(link.completed && link.getType() == TelephoneResponse){
                    TelephoneResponse prevResp = (TelephoneResponse) link.getResponse();
                    s += prevResp.message;
                }
            }
            return new TelephoneResponse(s + message);
        }
    }
```

### Create and Run Chainable

``` java
// Setup your "ChainLinks"
String[] words = new String[]{'Hello', 'World'};
for(Integer i = 0; i < words.size(); i++){
    String word  = words[i] + ' ';
    ChainableLink link = new ChainableLink(new TelephoneAction(word));
    links.add(link);
}

// Create the Chainable
Chainable chain = new Chainable(links);
String key = chain.key; //Save this somewhere if you want to check status / rerun

// enqueue executation
chain.enqueue();
```

### Rerun any failures

``` java
Chainable.reprocessChain(key, 0, true);
```
