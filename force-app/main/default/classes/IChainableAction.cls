/* Author: Charlie Jonas (charlie@callawaycloudconsulting.com)
 * Description: Interface that all actions must implement in order to be part of a Chainable
 */
public interface IChainableAction {
    Object execute(Chainable chain);
    Type getType();
    Type getResponseType();
}
