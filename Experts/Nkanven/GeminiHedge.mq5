//+------------------------------------------------------------------+
//|                                                  GeminiHedge.mq5 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin.com/in/nkondog"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Nkanven\GeminiHedge\Parameters.mqh>    //EA paramters
#include <Nkanven\GeminiHedge\TradingHour.mqh>   //Trading hours checks
#include <Nkanven\GeminiHedge\Prechecks.mqh>     //Trading conditions checks
#include <Nkanven\GeminiHedge\ScanPositions.mqh>     //Trading conditions checks
#include <Nkanven\GeminiHedge\LotSizeCal.mqh>    //Lot size calculator
#include <Nkanven\GeminiHedge\EntriesManager.mqh>    //Lot size calculator
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
   string instruments[];

   if(InpActivateDCAHedging)
     {
      string instruments[] = {InpInstrument1, InpInstrument2};
     }
   else
     {
      string instruments[] = {InpInstrument1};
     }

   for(int i=0; i<ArraySize(instruments); i++)
     {
      Spread = SymbolInfoInteger(instruments[i], SYMBOL_SPREAD);
      SymbolInfoTick(instruments[i],last_tick);
      gSymbol = instruments[i];


      CheckOperationHours();
      CheckPreChecks();
      ScanPositions();

      if(!gIsPreChecksOk)
         return;

      //Check if positions not exist


      //Check pending orders

      Print("Good for trading...");
      ExecuteEntry();
     }
  }
//+------------------------------------------------------------------+
