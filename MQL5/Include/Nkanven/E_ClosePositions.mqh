//+------------------------------------------------------------------+
//|                                             E_ClosePositions.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
CTrade trade;

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
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && iClose(Symb, PERIOD_CURRENT, 1) < Senkouspanb && iClose(Symb, PERIOD_CURRENT, 1) < Senkouspana)
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
        }

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
