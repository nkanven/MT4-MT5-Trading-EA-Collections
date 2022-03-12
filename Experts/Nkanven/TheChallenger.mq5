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

#include <Indicators/Trend.mqh>
#include <Indicators/Oscilators.mqh>
CiMA* ma;
CiMA* maHT;
CiATR* atr;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ma = new CiMA();
   ma.Create(gSymbol, InpTimeFrame, InpPeriods, InpAppliedPrice, InpMethod, PRICE_CLOSE);

   maHT = new CiMA();
   maHT.Create(gSymbol, InpHtTimeframe, InpHtPeriods, InpHtAppliedPrice, InpHtMethod, PRICE_CLOSE);

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

//isPinBar();

   CheckOperationHours();
   CheckPreChecks();
   ScanPositions();
//Get technical indicators values
   ma.Refresh(-1);
   gMa = ma.Main(1);

   atr.Refresh(-1);
   gAtr = atr.Main(1);

   maHT.Refresh(-1);
   gHtMa = maHT.Main(1);

   Print("ATR ", gAtr);
   Comment("gHtMa ", gHtMa);

   if(!gIsPreChecksOk)
      return;

   Print("Good for trading...");
Print("gEmergencyClose ", gEmergencyClose);
  drawdownWatcher();
   
   Print("gEmergencyClose ", gEmergencyClose);
  CloseTransactions();

   getSignal();
   ExecuteEntry();
  }
//+------------------------------------------------------------------+
