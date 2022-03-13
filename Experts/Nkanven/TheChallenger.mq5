//+------------------------------------------------------------------+
//|                                                TheChallenger.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Nkanven\TheChallenger\Parameters.mqh>    //EA paramters
#include <Nkanven\TheChallenger\TradingHour.mqh>   //Trading hours checks
#include <Nkanven\TheChallenger\Prechecks.mqh>     //Trading conditions checks
#include <Nkanven\TheChallenger\ScanPositions.mqh>     //Trading conditions checks
#include <Nkanven\TheChallenger\LotSizeCal.mqh>    //Lot size calculator
#include <Nkanven\TheChallenger\EntriesManager.mqh>    //Lot size calculator
#include <Nkanven\TheChallenger\CloseTransactions.mqh>  //Emergency close of transaction 
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
