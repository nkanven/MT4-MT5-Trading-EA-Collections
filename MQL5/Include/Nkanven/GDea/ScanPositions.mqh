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
   gTotalOpenOrders = 0;
   gTotalOpenBuy = 0;
   gTotalOpenSell = 0;
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
      if(PositionGetSymbol(i)!=gSymbol)
         continue;
      //If the order has Magic Number different from the Magic Number of the EA then we can ignore it
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber)
         continue;
      //If it is a buy order then increment the total count of buy orders
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         gTotalOpenBuy++;
      //If it is a sell order then increment the total count of sell orders
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         gTotalOpenSell++;
      //Increment the total orders count
      gTotalOpenPositions++;
      
      gPositionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      //Find what is the open time of the most recent trade and assign it to LastBarTraded
      //this is necessary to check if we already traded in the current candle
      if((datetime)PositionGetInteger(POSITION_TIME)>gLastBarTraded || gLastBarTraded==NULL)
         gLastBarTraded=(datetime)PositionGetInteger(POSITION_TIME);
     }
   Print("Total positions ", gTotalOpenOrders, " - Total buys ", gTotalOpenBuy, " - Total sells ", gTotalOpenSell);
   return true;
  }