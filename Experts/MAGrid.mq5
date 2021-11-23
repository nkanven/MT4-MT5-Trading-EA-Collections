//+------------------------------------------------------------------+
//|                                                       MAGrid.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
#property version   "1.00"

// Moving Average grid strategy
/*
Set pending orders x poinst above and below price.
If price above SMA, buy and set buy orders x time the ATR above and below price.
If price below SMA, sell and set sell orders x time the ATR above and below price.
Close all position at the close of the first candle crossing the moving average.

Open positions and set orders if there's nothing. At take profit, close all pending orders and reopen others
*/
#include <Indicators/Trend.mqh>
#include <Indicators/Oscilators.mqh>
CiMA* ma;
CiATR* atr;

#include <Nkanven\MAGrid\Parameters.mqh>   // Description of variables 
//#include <DL_ErrorHandling.mqh> // Error library
//#include <Nkanven\MAGrid\PreChecks.mqh> // Prechecks
//#include <Nkanven\MAGrid\TradingHour.mqh> //
//#include <Trade\Trade.mqh>
#include <Nkanven\MAGrid\ScanPositions.mqh>    // Scan for opened positions
//#include <Nkanven\MAGrid\CheckHistory.mqh> //Check transaction history
//#include <Nkanven\MAGrid\TradeManager.mqh> //Manage trade dynamic open and close conditions
#include <Nkanven\MAGrid\EntriesManager.mqh> // Check buy and sell entries signals and execute them
#include <Nkanven\MAGrid\LotSizeCal.mqh>   // Lot size calculate
//#include <Nkanven\MAGrid\ClosePositions.mqh>   // Close opened positions


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ma = new CiMA();
   ma.Create(gSymbol, PERIOD_CURRENT, InpFastPeriods, InpFastAppliedPrice, InpFastMethod, PRICE_CLOSE);

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
   SymbolInfoTick(_Symbol,last_tick);
   ma.Refresh(-1);
   gMa = ma.Main(1);

   atr.Refresh(-1);
   gAtr = atr.Main(1);
   ScanPositions();
   
   Print("Total transaction ", gTotalTransactions);
   if(gTotalTransactions>0)
      return;

   CheckSpread();
   EvaluateEntry();
   ExecuteEntry();
  }
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
