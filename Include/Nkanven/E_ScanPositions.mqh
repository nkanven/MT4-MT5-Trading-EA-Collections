//+------------------------------------------------------------------+
//|                                              E_ScanPositions.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Scan all positions to find the ones submitted by the EA
//NOTE This function is defined as bool because we want to return true if it is successful and false if it fails
bool ScanPositions()
  {
 
//Scan all the orders, retrieving some of the details
   TotalOpenOrders = 0;
   TotalOpenBuy = 0;
   TotalOpenSell = 0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      //If there is a problem reading the order print the error, exit the function and return false
      if(PositionGetTicket(i) == 0)
        {
         int Error=GetLastError();
         string ErrorText=GetLastErrorText(Error);
         Print("ERROR - Unable to select the order - ",Error," - ",ErrorText);
         return false;
        }
      //If the order is not for the instrument on chart we can ignore it
      if(PositionGetSymbol(i)!=Symb)
         continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(PositionGetInteger(POSITION_MAGIC)!=MagicNumber)
         continue;
      //If it is a buy order then increment the total count of buy orders
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         TotalOpenBuy++;
      //If it is a sell order then increment the total count of sell orders
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         TotalOpenSell++;
      //Increment the total orders count
      TotalOpenOrders++;
      //Find what is the open time of the most recent trade and assign it to LastBarTraded
      //this is necessary to check if we already traded in the current candle
      if((datetime)PositionGetInteger(POSITION_TIME)>LastBarTraded || LastBarTraded==0)
         LastBarTraded=(datetime)PositionGetInteger(POSITION_TIME);
     }
   Print("Total positions ", TotalOpenOrders, " - Total buys ", TotalOpenBuy, " - Total sells ", TotalOpenSell);
   return true;
  }