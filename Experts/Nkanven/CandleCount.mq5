//+------------------------------------------------------------------+
//|                                                  CandleCount.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Nkanven\CandleCount\Parameters.mqh>    //EA paramters
#include <Nkanven\CandleCount\TradingHour.mqh>   //Trading hours checks
#include <Nkanven\CandleCount\Prechecks.mqh>     //Trading conditions checks
#include <Nkanven\CandleCount\ScanPositions.mqh>     //Trading conditions checks
#include <Nkanven\CandleCount\LotSizeCal.mqh>    //Lot size calculator
#include <Nkanven\CandleCount\EntriesManager.mqh>    //Lot size calculator
#include <Nkanven\CandleCount\CloseTransactions.mqh>  //Emergency close of transaction 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <Indicators/Oscilators.mqh>
CiATR* atr;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   atr = new CiATR();
   atr.Create(gSymbol, InpTimeFrame, InpAtrPeriod);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   TimeCurrent(dt);

   SymbolInfoTick(_Symbol,last_tick);

   CheckOperationHours();
   CheckPreChecks();
   ScanPositions();

   //Get ATR values
   atr.Refresh(-1);
   gAtr = atr.Main(1);

   if(!gIsPreChecksOk)
      return;

   if(InpActivateRiskWatcher)
     {
      drawdownWatcher();
      CloseTransactions();
     }
   ExecuteEntry();
  }
//+------------------------------------------------------------------+
