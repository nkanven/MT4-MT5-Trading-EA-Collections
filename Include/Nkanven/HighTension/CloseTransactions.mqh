//+------------------------------------------------------------------+
//|                                            CloseTransactions.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

CTrade trade;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTransactions()
  {
   bool  result   =  true;
   int   cts      =  PositionsTotal();

   if(cts > 0)
     {
      for(int i = cts-1; i>=0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
           {
            if(PositionGetInteger(POSITION_MAGIC)==InpMagicNumber)
              {
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && currentColor == 1.0)
                 {
                  if(!trade.PositionClose(ticket))
                     Print("Error (", GetLastError(), ") while deleting all buy positions");
                 }
                 
                 if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && currentColor == 0.0)
                 {
                  if(!trade.PositionClose(ticket))
                     Print("Error (", GetLastError(), ") while deleting all buy positions");
                 }
              }
           }
         else
           {
            Print("Error (", GetLastError(), ") while selecting position by ticket");
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
