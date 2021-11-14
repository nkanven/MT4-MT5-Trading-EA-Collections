//+------------------------------------------------------------------+
//|                                            E_TradeManagement.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Done for the day after a profitable trade
//If closed trade was opened the day before, look for trade opportunities
double minProfitAllow = AccountInfoDouble(ACCOUNT_BALANCE)*(Breakevent/100);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeManager()
  {
   CanSell = true;
   CanBuy = true;

   if(lt.time == TimeToString(TimeCurrent(), TIME_DATE))
     {
      if(lt.type == DEAL_TYPE_BUY && lt.profit < 0)
        {
         CanBuy = false;
        }
      if(lt.type = DEAL_TYPE_SELL && lt.profit < 0)
        {
         CanSell = false;
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProfitRunner()
  {
  Print("Min acceptablbe profit ", minProfitAllow);
   ClosePosition = false;
   if(PositionProfit > minProfitAllow)
      FollowProfit=true;

   if(FollowProfit)
     {
      if(Kijunsen > iClose(Symb, _Period, 1) && TotalOpenBuy > 0)
        {
         ClosePosition = true;
        }
      if(Kijunsen < iClose(Symb, _Period, 1) && TotalOpenSell > 0)
        {
         ClosePosition = true;
        }
     }
     Print("Looking to close this position ", ClosePosition, " Follow profit ", FollowProfit);
  }
//+------------------------------------------------------------------+
