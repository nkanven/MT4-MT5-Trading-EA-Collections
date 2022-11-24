//+------------------------------------------------------------------+
//|                                                  Equilibrium.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Indicators/Trend.mqh>
#include <Indicators\Oscilators.mqh>

CiIchimoku* ichimoku;
CiADX* adx;
CiATR* atr;

#include <E_Parameters.mqh>   // Description of variables 
#include <DL_ErrorHandling.mqh> // Error library
#include <DL_PreChecks.mqh> // Prechecks
#include <DL_CheckOperationHours.mqh> // 
#include <Trade\Trade.mqh>
#include <DL_ScanPositions.mqh>    // Scan for opened positions
#include <E_CheckHistory.mqh> //Check transaction history
#include <E_TradeManagement.mqh> //Manage trade dynamic open and close conditions
#include <E_EntriesManagement.mqh> // Check buy and sell entries signals and execute them
#include <DL_LotSizeCal.mqh>   // Lot size calculate
//#include <DL_TradingBoundaries.mqh>  //Draw trading range boundaries on chart
#include <E_ClosePositions.mqh>   // Close opened positions

//TODO: Add ADX to filter ranging market
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ichimoku = new CiIchimoku();
   ichimoku.Create(Symb, PERIOD_CURRENT, tenkan_sen, kijun_sen, senkou_span_b);
   
   atr = new CiATR();
   atr.Create(Symb, PERIOD_CURRENT, atr_period);
//   adx = new CiADX();
//   adx.Create(Symb, PERIOD_CURRENT, adx_period);
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
ichimoku.Refresh(-1);
Tenkansen = ichimoku.TenkanSen(0);
Kijunsen = ichimoku.KijunSen(0);
Senkouspana = ichimoku.SenkouSpanA(-26);
Senkouspanb = ichimoku.SenkouSpanB(-26);
BwSenkouspana = ichimoku.SenkouSpanA(26);
BwSenkouspanb = ichimoku.SenkouSpanB(26);
Chinkouspan = ichimoku.ChinkouSpan(26);

atr.Refresh(-1);
Atr = atr.Main(1);
/*adx.Refresh(-1);
AdxMain = adx.Main(1);
AdxPlus = adx.Plus(1);
AdxMinus = adx.Minus(1);*/

SymbolInfoTick(_Symbol,last_tick);
//ScanPositions scans all the opened positions and collect statistics, if an error occurs it skips to the next price change
   
   if(!ScanPositions())
      return;
   CloseOpenPositions();
   CheckHistory();
   CheckSpread();
   EvaluateEntry();
   ProfitRunner();
   ExecuteEntry();

   Comment(
      "Expert Advisor by Anselme Nkondog (c) 2021\n");
   return;
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
   TotalOpenOrders=0;

   SignalEntry=SIGNAL_ENTRY_NEUTRAL;
   SignalExit=SIGNAL_EXIT_NEUTRAL;
   Print("Variables intialized");
  }

//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   long SpreadCurr=Spread;
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
