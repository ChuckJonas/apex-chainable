// @isTest
public class ChainTestingActions {

    public static ChainableLink[] createTelephoneChain(String s) {
        String[] words = s.split(' ');

        ChainableLink[] links = new List<ChainableLink>{};
        for (Integer i = 0; i < words.size(); i++) {
            String word = words[i];
            ChainableLink link = new ChainableLink(new TelephoneAction(word));
            links.add(link);
        }
        system.debug(links.size());
        return links;
    }

    //Example of how an action can read response from previous actions
    public class TelephoneAction extends ChainableAction {
        private String message;
        public TelephoneAction(String message) {
            this.message = message;
        }

        public override Type getType() {
            return TelephoneAction.class;
        }

        public override Type getResponseType() {
            return TelephoneResponse.class;
        }

        public override Object execute(Chainable chain) {
            //read past messages
            if (chain.currentLink.parent == null) {
                return new TelephoneResponse(this.message);
            }
            TelephoneResponse previousMessage = (TelephoneResponse) chain.currentLink.parent.getResponse();
            return new TelephoneResponse(previousMessage.message + ' ' + this.message);
        }
    }

    public class TelephoneResponse {
        public String message;

        public TelephoneResponse(String message) {
            this.message = message;
        }
    }

    //Example of an action which can generate & append other actions
    public class AppendAction extends ChainableAction {
        private String message;
        public AppendAction(String message) {
            this.message = message;
        }

        public override Type getType() {
            return AppendAction.class;
        }

        public override Object execute(Chainable chain) {
            chain.appendLinks(createTelephoneChain(message));
            return null;
        }
    }

    public static Integer EXCEPTION_EXECUTIONS = 0;
    public static String CASE_NAME = 'abc123';
    public class ExceptionAction extends ChainableAction {
        public Integer succeedAfter;
        public ExceptionAction(Integer succeedAfter) {
            this.succeedAfter = succeedAfter;
        }

        public ExceptionAction() {
          this(999);
        }

        public override Type getType() {
            return ExceptionAction.class;
        }

        public override Object execute(Chainable chain) {
            EXCEPTION_EXECUTIONS++;
            Case c = new Case(Subject = CASE_NAME);
            insert c;
            if(EXCEPTION_EXECUTIONS <= succeedAfter){
              Decimal d = 1 / 0;
            }
            return null;
        }
    }
}
