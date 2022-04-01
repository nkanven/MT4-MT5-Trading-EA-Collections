//+------------------------------------------------------------------+
//|                                                  HighTension.mq5 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin/in/nkondog.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin/in/nkondog.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Nkanven\HighTension\Parameters.mqh>    //EA paramters
#include <Nkanven\HighTension\Prechecks.mqh>     //Trading conditions checks
#include <Nkanven\HighTension\ScanPositions.mqh>     //Trading conditions checks
#include <Nkanven\HighTension\LotSizeCal.mqh>    //Lot size calculator
#include <Nkanven\HighTension\EntriesManager.mqh>    //Lot size calculator
#include <Nkanven\HighTension\CloseTransactions.mqh>  //Emergency close of transaction 

int handle;
const int indexMA     = 0;
const int indexColor  = 1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handle = iCustom(gSymbol, PERIOD_CURRENT, "Nkanven\MA-Slope", InpPeriods, InpMethod, InpAppliedPrice);

   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error %i ", GetLastError());
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   TimeCurrent(dt);

   SymbolInfoTick(_Symbol,last_tick);

   CheckPreChecks();
   if(!gIsPreChecksOk)
      return;

   ScanPositions();
   if(!newBar())
      return;


   int cnt = CopyBuffer(handle, indexMA, 0, 3, bufferMA);
   if(cnt<3)
      return;
   cnt = CopyBuffer(handle, indexColor, 0, 3, bufferColor);

   currentMA    = bufferMA[1];
   currentColor = bufferColor[1];

   Print("Signal ", tradeSignal(), " Stop loss ", getAutoStopLoss(tradeSignal()));

   Print("currentMA ", currentMA, " currentColor ", currentColor);

   CloseTransactions();
   ExecuteEntry();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar()
  {

   static datetime prevTime    = 0;
   datetime        currentTime = iTime(gSymbol, PERIOD_CURRENT, 0);
   if(currentTime != prevTime)
     {
      prevTime = currentTime;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
