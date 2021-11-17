//+------------------------------------------------------------------+
//|                                                     GDeaLite.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Nkanven\GDea\Parameters.mqh>   // Description of variables 
#include <DL_ErrorHandling.mqh> // Error library
#include <Nkanven\GDea\PreChecks.mqh> // Prechecks
#include <Nkanven\GDea\TradingHour.mqh> // 
#include <Trade\Trade.mqh>
#include <Nkanven\GDea\ScanPositions.mqh>    // Scan for opened positions
#include <Nkanven\GDea\CheckHistory.mqh> //Check transaction history
#include <Nkanven\GDea\TradeManager.mqh> //Manage trade dynamic open and close conditions
#include <Nkanven\GDea\EntriesManager.mqh> // Check buy and sell entries signals and execute them
#include <Nkanven\GDea\LotSizeCal.mqh>   // Lot size calculate
#include <Nkanven\GDea\ClosePositions.mqh>   // Close opened positions
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
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
   
  }
//+------------------------------------------------------------------+

//Initialize variables
void InitializeVariables()
  {
   IsNewCandle=false;
   IsTradedThisBar=false;
   IsOperatingHours=false;
   IsSpreadOK=false;

   LotSize=DefaultLotSize;
   TickValue=0;

   TotalOpenBuy=0;
   TotalOpenSell=0;

   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   SignalExit=SIGNAL_EXIT_NEUTRAL;
   Print("Variables intialized");
  }

//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   double SpreadCurr=SymbolInfoInteger(mSymbol, SYMBOL_SPREAD);
   Print("Spread ", SpreadCurr);
   if(SpreadCurr<=MaxSpread)
     {
      IsSpreadOK=true;
     }
   else
     {
      IsSpreadOK=false;
     }
  }
//+------------------------------------------------------------------+
