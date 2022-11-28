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
   ulong theTicket;
   double positionProfit = 0.0;

   if(cts > 0)
     {
      for(int i = cts-1; i>=0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
           {
            if(PositionGetInteger(POSITION_MAGIC)==InpMagicNumber)
              {
               if(positionProfit > PositionGetDouble(POSITION_PROFIT))
                 {
                  positionProfit = PositionGetDouble(POSITION_PROFIT);
                  theTicket = ticket;
                 }
              }
           }
         else
           {
            Print("Error (", GetLastError(), ") while selecting position by ticket");
           }
        }
      if(gEmergencyClose)
        {
         if(!trade.PositionClose(theTicket))
            Print("Error (", GetLastError(), ") while deleting all buy positions");
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawdownWatcher()
  {
   double amountDiff, equity, balance, percentDiff;
   balance=AccountInfoDouble(ACCOUNT_BALANCE);
   equity=AccountInfoDouble(ACCOUNT_EQUITY);
   gEmergencyClose = false;

   if(equity < balance)
     {
      amountDiff = balance - equity;
      percentDiff = (amountDiff*100)/balance;

      Print("amountDiff ", amountDiff, " percentDiff ", percentDiff, " InpMaxDrawdown ", InpMaxDrawdown);

      if(InpMaxDrawdown < percentDiff)
        {
         gEmergencyClose = true;
        }
     }
  }
//+------------------------------------------------------------------+
