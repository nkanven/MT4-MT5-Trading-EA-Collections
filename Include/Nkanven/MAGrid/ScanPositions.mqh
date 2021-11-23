//+------------------------------------------------------------------+
//|                                                ScanPositions.mqh |
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
   gTotalOpenOrders = OrdersTotal();
   gTotalPositions = PositionsTotal();
   gTotalBuyPositions = 0;
   gTotalSellPositions = 0;
   gTotalTransactions = gTotalOpenOrders+gTotalPositions;

   for(int i=0; i<gTotalPositions; i++)
     {
      //If there is a problem reading the order print the error, exit the function and return false
      if(PositionGetTicket(i) == 0)
        {
         int Error=GetLastError();
         //string ErrorText=GetLastErrorText(Error);
         //Print("ERROR - Unable to select the order - ",Error," - ",ErrorText);
         Print("ERROR - Unable to select the order - ",Error," - ",Error);
         return false;
        }
      //If the order is not for the instrument on chart we can ignore it
      if(PositionGetSymbol(i)!=gSymbol)
         continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber)
         continue;
      //If it is a buy order then increment the total count of buy orders
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         gTotalBuyPositions++;
      //If it is a sell order then increment the total count of sell orders
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         gTotalSellPositions++;

      //Find what is the open time of the most recent trade and assign it to LastBarTraded
      //this is necessary to check if we already traded in the current candle
      if((datetime)PositionGetInteger(POSITION_TIME)>gLastBarTraded || gLastBarTraded==NULL)
         gLastBarTraded=(datetime)PositionGetInteger(POSITION_TIME);
     }
   Print("Total positions ", gTotalPositions, " - Total buys ", gTotalBuyPositions, " - Total sells ", gTotalSellPositions);
   return true;
  }