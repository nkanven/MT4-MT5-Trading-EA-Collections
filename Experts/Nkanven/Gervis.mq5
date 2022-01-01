//+------------------------------------------------------------------+
//|                                                       Gervis.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Indicators/Trend.mqh>
#include <Indicators/Oscilators.mqh>

CiMA* sma;
CiMA* ssma;

#include <Nkanven\Gervis\Parameters.mqh>   // Description of variables 
#include <DL_ErrorHandling.mqh> // Error library
#include <Nkanven\Gervis\PreChecks.mqh> // Prechecks
#include <Nkanven\Gervis\TradingHour.mqh> // 
#include <Trade\Trade.mqh>
#include <Nkanven\Gervis\ScanPositions.mqh>    // Scan for opened positions
#include <Nkanven\Gervis\CheckHistory.mqh> //Check transaction history
#include <Nkanven\Gervis\TradeManager.mqh> //Manage trade dynamic open and close conditions
#include <Nkanven\Gervis\EntriesManagerDCA.mqh> // Check buy and sell entries signals and execute them
#include <Nkanven\Gervis\LotSizeCal.mqh>   // Lot size calculate
#include <Nkanven\Gervis\ClosePositions.mqh>   // Close opened positions
#include <Nkanven\Gervis\HighestPriceLevel.mqh> 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //sma = new CiMA();
   //ssma = new CiMA();

   //sma.Create(gSymbol, PERIOD_CURRENT, InpMAPeriods, InpMAAppliedPrice, InpMAMethod, PRICE_CLOSE);
   //ssma.Create(gSymbol, PERIOD_CURRENT, 200, InpMAAppliedPrice, InpMAMethod, PRICE_CLOSE);
   InitializeVariables();
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

   //sma.Refresh(-1);
   //ssma.Refresh(-1);
   TimeCurrent(dt);

   //gSma = sma.Main(1);
   //gSsma = ssma.Main(1);
   CheckOperationHours();

   gCandleHigh = iHigh(gSymbol, PERIOD_CURRENT, 1);
   gCandleLow = iLow(gSymbol, PERIOD_CURRENT, 1);
   gCandleOpen = iOpen(gSymbol, PERIOD_CURRENT, 1);
   gCandleClose = iClose(gSymbol, PERIOD_CURRENT, 1);

   gMinStopLoss =MathAbs(SymbolInfoInteger(gSymbol, SYMBOL_TRADE_STOPS_LEVEL))+20;

//isQualifiedCandle(0);
   OrderClose();
   ScanPositions();
   if(gTotalOpenPositions==0)
      gSignalEntry = SIGNAL_ENTRY_BUY;

   CheckSpread();
   entryConditions();
   EvaluateEntry();
   drawLine();
   ExecuteEntry();

   Comment(
      "Expert Advisor by Anselme Nkondog (c) 2021\n "+
      " Hour " + dt.hour + " Min "+ dt.min+"\n"
      " Last Highest Price " + gLastHighestPrice + " Price %change "+ gPriceChange);

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
