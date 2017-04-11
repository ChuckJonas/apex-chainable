# apex-chainable
A framework for managing multiple asynchronous processes in Salesforce.  Uses Queuable to chain multiple processes together.

## Features

- Allows sequential execution multiple asyncronous actions
- Access to "Results" produced by executions further up the chain
- Fault tolerent.  Failures are tracked and chain can be reprocessed
- Client Side event library to easily update user of chain status

## Use Cases

*Simple*: You have a client facing page that needs to do more work than can be handled in a single execution context.  The user should be notifed of the status of this work in realtime (progress bar with error handeling) 

*Complex*: You need to perform multiple actions that cannot be completed in a single excution context.  Each actions is depedant on the outcome of the previous action.  If any part of the action fails, you need the ability to correct the errors and pick up where you left off.

## Limitations
- `ChainAction` implemenations must be serializable!
- The practicial limit to number of chains seems to be somewhere around 150-200.  While in theory there should be no limit here (according to official documentation), things start to slow down and eventually salesforce kills it off. 

## Usage

### Implement ChainAction

``` apex
//an example class that just outputs the response
public class ChainTestingAction extends ChainableAction{

    private String message;
    public ChainTestingAction(String message){
        this.message = message;
    }

    public override void execute(ChainLink link){

        //set my message
        ChainableResponse resp = new ChainableResponse();
        resp.message = message;
        link.response = JSON.serialize(resp);

        //read past messages
        String s = '';
        while(link != null){
            System.debug(link.position);
            System.debug(link.response);
            resp = (ChainableResponse)JSON.deserialize(link.response, ChainableResponse.class);
            s += resp.message;
            link = link.parent;
        }

        System.debug(s);
    }


    public class ChainableResponse{
        public String message;
    }

}
```

### Create and Run Chainable


### Display Progress

### Rerun chain
