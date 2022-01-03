//+------------------------------------------------------------------+
//|                                               A_TradeManager.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

void ProfitRunner()
  {
   if(ProfitRun)
     {
      if(iClose(Symb, _Period, 1) < iClose(Symb, _Period, 2) && TotalOpenBuy > 0)
        {
         ClosePosition = true;
        }
      if(iClose(Symb, _Period, 1) > iClose(Symb, _Period, 2) && TotalOpenSell > 0)
        {
         ClosePosition = true;
        }
     }
     Print("Looking to close this position ", ClosePosition);
  }