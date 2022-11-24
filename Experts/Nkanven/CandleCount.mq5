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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Indicators/Trend.mqh>

CiMA* sma;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   sma = new CiMA();
   sma.Create(gSymbol, InpTimeFrame, InpPeriods, InpAppliedPrice, InpMethod, PRICE_CLOSE);
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

   SymbolInfoTick(InpInstrument1,last_tick);
   SymbolInfoTick(InpInstrument2, blast_tick);

   sma.Refresh(-1);
   gSma = sma.Main(1);

   CheckOperationHours();
   CheckPreChecks();
   ScanPositions();

   if(!gIsPreChecksOk)
      return;

   Print("Good for trading...");
   ExecuteEntry();
  }
//+------------------------------------------------------------------+
