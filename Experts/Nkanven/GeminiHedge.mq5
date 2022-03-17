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
#include <Nkanven\GeminiHedge\DCAManager.mqh>    //DCA manager
#include <Nkanven\GeminiHedge\LotSizeCal.mqh>    //Lot size calculator
#include <Nkanven\GeminiHedge\EntriesManager.mqh>    //Trade entries manager
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
     Print("DCA Hedging is activated");
     ArrayResize(instruments,2);
      instruments[0] = InpInstrument1;
      instruments[1] = InpInstrument2;
     }
   else
     {
     Print("DCA Hedging is not activated");
     ArrayResize(instruments,1);
      instruments[0] = InpInstrument1;
     }

Print("Instrument size", ArraySize(instruments));
   for(int i=0; i<ArraySize(instruments); i++)
     {
      Spread = SymbolInfoInteger(instruments[i], SYMBOL_SPREAD);
      SymbolInfoTick(instruments[i],last_tick);
      Print("last_tick ask ", last_tick.ask, " instruments ", instruments[i]);
      gSymbol = instruments[i];
      point = SymbolInfoDouble(gSymbol, SYMBOL_POINT);
      
      Print("Point ", InpDefaultTakeProfit);


      CheckOperationHours();
      CheckPreChecks();
      ScanPositions();

      if(!gIsPreChecksOk)
         return;

      DcaManager();

      Print("Good for trading...");
      ExecuteEntry();
     }
  }
//+------------------------------------------------------------------+
