//+------------------------------------------------------------------+
//|                                           A_PositionsManager.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
CTrade trade;

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

// We declare a function CloseOpenPositions of type int and we want to return
// the number of positions that are closed.
void CloseOpenPositions()
  {

   int TotalClose=0;  // We want to count how many orders have been closed.
   int c_slippage = Slippage;
   Print("Close position status ", ClosePosition);
// Normalization of the slippage.
   if(_Digits==3 || _Digits==5)
     {
      c_slippage=c_slippage*10;
     }

// We scan all the orders backwards.
// This is required as if we start from the first order, we will have problems with the counters and the loop.
   for(int i=PositionsTotal()-1; i>=0; i--)
     {

      ulong ticket = PositionGetTicket(i);

      Print("Position profit is ", PositionGetDouble(POSITION_PROFIT));
      PositionProfit = PositionGetDouble(POSITION_PROFIT);
      /*if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && iClose(Symb, PERIOD_CURRENT, 1) < Senkouspanb && iClose(Symb, PERIOD_CURRENT, 1) < Senkouspana)
        {
         // We select the order of index i, selecting by position and from the pool of market/pending trades.
         //If the selection is successful we try to close the order.
         if(trade.PositionClose(ticket, c_slippage))
           {
            TotalClose++;
           }
         else
           {
            // If the order fails to be closed, we print the error.
            Print("Order failed to close with error - ",GetLastError());
           }
        }

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && iClose(Symb, PERIOD_CURRENT, 1) > Senkouspanb && iClose(Symb, PERIOD_CURRENT, 1) > Senkouspana)
        {
         // We select the order of index i, selecting by position and from the pool of market/pending trades.
         //If the selection is successful we try to close the order.
         if(trade.PositionClose(ticket, c_slippage))
           {
            TotalClose++;
           }
         else
           {
            // If the order fails to be closed, we print the error.
            Print("Order failed to close with error - ",GetLastError());
           }
        }*/

      if(ClosePosition)
        {
         if(trade.PositionClose(ticket, c_slippage))
           {
            TotalClose++;
            ClosePosition = false;
           }
         else
           {
            // If the order fails to be closed, we print the error.
            Print("Order failed to close with error - ",GetLastError());
           }
        }
      // We can use a delay if the execution is too fast.
      // Sleep() will wait X milliseconds before proceeding with the code.
      // Sleep(300);
     }
  }
//+------------------------------------------------------------------+
