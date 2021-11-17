//+------------------------------------------------------------------+
//|                                                     GDeaLite.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Indicators/Trend.mqh>
#include <Indicators/Oscilators.mqh>

CiMA* fsma;
CiMA* ssma;

CiATR* atr;

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
   fsma = new CiMA();
   ssma = new CiMA();

   fsma.Create(gSymbol, PERIOD_CURRENT, InpFastPeriods, InpFastAppliedPrice, InpFastMethod, PRICE_CLOSE);
   ssma.Create(gSymbol, PERIOD_CURRENT, InpSlowPeriods, InpFastAppliedPrice, InpSlowMethod, PRICE_CLOSE);

   atr = new CiATR();
   atr.Create(gSymbol, PERIOD_CURRENT, InpAtrPeriod);
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
   gIsNewCandle=false;
   gIsTradedThisBar=false;
   gIsOperatingHours=false;
   gIsSpreadOK=false;

   gLotSize=InpDefaultLotSize;
   gTickValue=0;

   gTotalOpenBuy=0;
   gTotalOpenSell=0;

   gSignalEntry=SIGNAL_ENTRY_NEUTRAL;
   gSignalExit=SIGNAL_EXIT_NEUTRAL;
   Print("Variables intialized");
  }

//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   long SpreadCurr=SymbolInfoInteger(gSymbol, SYMBOL_SPREAD);
   Print("Spread ", SpreadCurr);
   if(SpreadCurr<=InpMaxSpread)
     {
      gIsSpreadOK=true;
     }
   else
     {
      gIsSpreadOK=false;
     }
  }
//+------------------------------------------------------------------+
