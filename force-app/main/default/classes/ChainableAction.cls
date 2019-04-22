/* Author: Charlie Jonas (charlie@callawaycloudconsulting.com)
 *  Description: Base class to ease implementation of IChainableAction
*/
public abstract class ChainableAction implements IChainableAction{

    public abstract Object execute(Chainable chain);

    //must be overwritten if using inner class!
    public virtual Type getType(){
        return Type.forName(String.valueOf(this).split(':')[0]);
    }

    //response type is stored on each chain record
    public virtual Type getResponseType(){
        return void.class;
    }

}
