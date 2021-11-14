#property link          "https://www.earnforex.com/"
#property version       "1.00"
#property strict
#property copyright     "EarnForex.com - 2020"
#property description   "This is list of the available MT4 errors" 
#property description   " "
#property description   "Find More on EarnForex.com"

//This functions returns a string corresponding to the description of an error
//Complete list of error available https://book.mql4.com/appendix/errors
string GetLastErrorText(int Error){
   string Text="Error Not Defined";
   if(Error==ERR_NO_ERROR) Text="No error returned.";
   if(Error==ERR_NO_RESULT) Text="No error returned, but the result is unknown.";
   if(Error==ERR_COMMON_ERROR) Text="Common error.";
   if(Error==ERR_INVALID_TRADE_PARAMETERS) Text="Invalid trade parameters.";
   if(Error==ERR_SERVER_BUSY) Text="Trade server is busy.";
   if(Error==ERR_OLD_VERSION) Text="Old version of the client terminal.";
   if(Error==ERR_NO_CONNECTION) Text="No connection with trade server.";
   if(Error==ERR_NOT_ENOUGH_RIGHTS) Text="Not enough rights.";
   if(Error==ERR_TOO_FREQUENT_REQUESTS) Text="Too frequent requests.";
   if(Error==ERR_MALFUNCTIONAL_TRADE) Text="Malfunctional trade operation.";
   if(Error==ERR_ACCOUNT_DISABLED) Text="Account disabled.";
   if(Error==ERR_INVALID_ACCOUNT) Text="Invalid account.";
   if(Error==ERR_TRADE_TIMEOUT) Text="Trade timeout.";
   if(Error==ERR_INVALID_PRICE) Text="Invalid price.";
   if(Error==ERR_INVALID_STOPS) Text="Invalid stops.";
   if(Error==ERR_INVALID_TRADE_VOLUME) Text="Invalid trade volume.";
   if(Error==ERR_MARKET_CLOSED) Text="Market is closed.";
   if(Error==ERR_TRADE_DISABLED) Text="Trade is disabled.";
   if(Error==ERR_NOT_ENOUGH_MONEY) Text="Not enough money.";
   if(Error==ERR_PRICE_CHANGED) Text="Price changed.";
   if(Error==ERR_OFF_QUOTES) Text="Off quotes.";
   if(Error==ERR_BROKER_BUSY) Text="Broker is busy.";
   if(Error==ERR_REQUOTE) Text="Requote.";
   if(Error==ERR_ORDER_LOCKED) Text="Order is locked.";
   if(Error==ERR_LONG_POSITIONS_ONLY_ALLOWED) Text="Long positions only allowed.";
   if(Error==ERR_TOO_MANY_REQUESTS) Text="Too many requests.";
   if(Error==ERR_TRADE_MODIFY_DENIED) Text="Modification denied because an order is too close to market.";
   if(Error==ERR_TRADE_CONTEXT_BUSY) Text="Trade context is busy.";
   if(Error==ERR_TRADE_EXPIRATION_DENIED) Text="Expirations are denied by broker.";
   if(Error==ERR_TRADE_TOO_MANY_ORDERS) Text="The amount of opened and pending orders has reached the limit set by a broker.";
   if(Error==ERR_NO_MQLERROR) Text="No error.";
   if(Error==ERR_WRONG_FUNCTION_POINTER) Text="Wrong function pointer.";
   if(Error==ERR_ARRAY_INDEX_OUT_OF_RANGE) Text="Array index is out of range.";
   if(Error==ERR_RECURSIVE_STACK_OVERFLOW) Text="Recursive stack overflow.";
   if(Error==ERR_NO_MEMORY_FOR_TEMP_STRING) Text="No memory for temp string.";
   if(Error==ERR_NOT_INITIALIZED_STRING) Text="Not initialized string.";
   if(Error==ERR_NOT_INITIALIZED_ARRAYSTRING) Text="Not initialized string in an array.";
   if(Error==ERR_NO_MEMORY_FOR_ARRAYSTRING) Text="No memory for an array string.";
   if(Error==ERR_TOO_LONG_STRING) Text="Too long string.";
   if(Error==ERR_REMAINDER_FROM_ZERO_DIVIDE) Text="Remainder from zero divide.";
   if(Error==ERR_ZERO_DIVIDE) Text="Zero divide.";
   if(Error==ERR_UNKNOWN_COMMAND) Text="Unknown command.";
   if(Error==ERR_WRONG_JUMP) Text="Wrong jump.";
   if(Error==ERR_NOT_INITIALIZED_ARRAY) Text="Not initialized array.";
   if(Error==ERR_DLL_CALLS_NOT_ALLOWED) Text="DLL calls are not allowed.";
   if(Error==ERR_CANNOT_LOAD_LIBRARY) Text="Cannot load library.";
   if(Error==ERR_CANNOT_CALL_FUNCTION) Text="Cannot call function.";
   if(Error==ERR_SYSTEM_BUSY) Text="System is busy.";
   if(Error==ERR_SOME_ARRAY_ERROR) Text="Some array error.";
   if(Error==ERR_CUSTOM_INDICATOR_ERROR) Text="Custom indicator error.";
   if(Error==ERR_INCOMPATIBLE_ARRAYS) Text="Arrays are incompatible.";
   if(Error==ERR_GLOBAL_VARIABLE_NOT_FOUND) Text="Global variable not found.";
   if(Error==ERR_FUNCTION_NOT_CONFIRMED) Text="Function is not confirmed.";
   if(Error==ERR_SEND_MAIL_ERROR) Text="Mail sending error.";
   if(Error==ERR_STRING_PARAMETER_EXPECTED) Text="String parameter expected.";
   if(Error==ERR_INTEGER_PARAMETER_EXPECTED) Text="Integer parameter expected.";
   if(Error==ERR_DOUBLE_PARAMETER_EXPECTED) Text="Double parameter expected.";
   if(Error==ERR_ARRAY_AS_PARAMETER_EXPECTED) Text="Array as parameter expected.";
   if(Error==ERR_HISTORY_WILL_UPDATED) Text="Requested history data in updating state.";
   if(Error==ERR_TRADE_ERROR) Text="Some error in trade operation execution.";
   if(Error==ERR_END_OF_FILE) Text="End of a file.";
   if(Error==ERR_SOME_FILE_ERROR) Text="Some file error.";
   if(Error==ERR_WRONG_FILE_NAME) Text="Wrong file name.";
   if(Error==ERR_TOO_MANY_OPENED_FILES) Text="Too many opened files.";
   if(Error==ERR_CANNOT_OPEN_FILE) Text="Cannot open file.";
   if(Error==ERR_NO_ORDER_SELECTED) Text="No order selected.";
   if(Error==ERR_UNKNOWN_SYMBOL) Text="Unknown symbol.";
   if(Error==ERR_INVALID_PRICE_PARAM) Text="Invalid price.";
   if(Error==ERR_INVALID_TICKET) Text="Invalid ticket.";
   if(Error==ERR_TRADE_NOT_ALLOWED) Text="Trade is not allowed.";
   if(Error==ERR_LONGS_NOT_ALLOWED) Text="Longs are not allowed.";
   if(Error==ERR_SHORTS_NOT_ALLOWED) Text="Shorts are not allowed.";
   if(Error==ERR_OBJECT_ALREADY_EXISTS) Text="Object already exists.";
   if(Error==ERR_UNKNOWN_OBJECT_PROPERTY) Text="Unknown object property.";
   if(Error==ERR_OBJECT_DOES_NOT_EXIST) Text="Object does not exist.";
   if(Error==ERR_UNKNOWN_OBJECT_TYPE) Text="Unknown object type.";
   if(Error==ERR_NO_OBJECT_NAME) Text="No object name.";
   if(Error==ERR_OBJECT_COORDINATES_ERROR) Text="Object coordinates error.";
   if(Error==ERR_NO_SPECIFIED_SUBWINDOW) Text="No specified subwindow.";
   if(Error==ERR_SOME_OBJECT_ERROR) Text="Some error in object operation.";
   
   return Text;
}