//+------------------------------------------------------------------+
//|                                           DL_TradeManagement.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

bool ShouldTrade()
  {
   //double minProfitAllow = ((AccountInfoDouble(ACCOUNT_BALANCE)*MaxRiskPerTrade)/100)*(TakeProfitPercent*MinStopTradeProfit);
Print("1 Profit ", lt.profit, " Hist time ", lt.time, " current time ", TimeToString(TimeCurrent(), TIME_DATE));
   if(lt.time == TimeToString(TimeCurrent(), TIME_DATE) && lt.profit > 0)
     {
     Print("2 Profit ", lt.profit);
      return false;
     }
     return true;
  }
//+------------------------------------------------------------------+
