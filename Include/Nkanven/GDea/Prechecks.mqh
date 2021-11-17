//+------------------------------------------------------------------+
//|                                                    Prechecks.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//Perform integrity checks when the EA is loaded
void CheckPreChecks()
  {
   gIsPreChecksOk=true;
//Check if Live Trading is enabled in MT4
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      gIsPreChecksOk=false;
      Print("Live Trading is not enabled, please enable it in MT4 and chart settings");
      return;
     }
//Check if the default stop loss you are setting in above the minimum and below the maximum
   if(InpDefaultStopLoss<InpMinStopLoss || InpDefaultStopLoss>InpMaxStopLoss)
     {
      gIsPreChecksOk=false;
      Print("Default Stop Loss must be between Minimum and Maximum Stop Loss Allowed");
      return;
     }
//Check if the default take profit you are setting in above the minimum and below the maximum
   if(InpDefaultTakeProfit<InpMinTakeProfit || InpDefaultTakeProfit>InpMaxTakeProfit)
     {
      gIsPreChecksOk=false;
      Print("Default Take Profit must be between Minimum and Maximum Take Profit Allowed");
      return;
     }
//Check if the Lot Size is between the minimum and maximum
   if(InpDefaultLotSize<InpMinLotSize || InpDefaultLotSize>InpMaxLotSize)
     {
      gIsPreChecksOk=false;
      Print("Default Lot Size must be between Minimum and Maximum Lot Size Allowed");
      return;
     }
//Slippage must be >= 0
   if(InpSlippage<0)
     {
      gIsPreChecksOk=false;
      Print("Slippage must be a positive value");
      return;
     }
//MaxSpread must be >= 0
   if(InpMaxSpread<0)
     {
      gIsPreChecksOk=false;
      Print("Maximum Spread must be a positive value");
      return;
     }
//MaxRiskPerTrade is a % between 0 and 100
   if(InpMaxRiskPerTrade<0 || InpMaxRiskPerTrade>100)
     {
      gIsPreChecksOk=false;
      Print("Maximum Risk Per Trade must be a percentage between 0 and 100");
      return;
     }
  }
