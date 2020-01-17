// @isTest
public class ChainTestingActions{

    public static ChainableLink[] createTelephoneChain(String s){
        String[] words = s.split(' ');

        ChainableLink[] links = new ChainableLink[]{};
        for(Integer i = 0; i < words.size(); i++){
            String word  = words[i] + ' ';
            ChainableLink link = new ChainableLink(new TelephoneAction(word));
            links.add(link);
        }
        system.debug(links.size());
        return links;
    }

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
                if(link.completed){
                    TelephoneResponse prevResp = (TelephoneResponse) link.getResponse();
                    s += prevResp.message;
                }
            }
            return new TelephoneResponse(s + message);
        }
    }

    public class TelephoneResponse{
        public String message;

        public TelephoneResponse(String message){
            this.message = message;
        }
    }

    //Example of an action which can generate & append other actions
    public class AppendAction extends ChainableAction{
        private String message;
        public AppendAction(String message){
            this.message = message;
        }

        public override Type getType(){
            return AppendAction.class;
        }

        public override Object execute(Chainable chain){
            chain.appendLinks(createTelephoneChain(message));
            return null;
        }
    }

     public class ExceptionAction extends ChainableAction{
        public String caseName;
        public ExceptionAction(String caseName){
            this.caseName = caseName;
        }

        public override Type getType(){
            return ExceptionAction.class;
        }

        public override Object execute(Chainable chain){
            Case c = new Case(
                Subject = caseName
            );
			System.debug(c);
            insert c;
            Decimal d = 1/0;
            return null;
        }
    }

}
