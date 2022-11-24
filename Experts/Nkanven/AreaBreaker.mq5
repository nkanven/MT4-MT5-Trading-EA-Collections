//+------------------------------------------------------------------+
//|                                                  AreaBreaker.mq5 |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <A_Parameters.mqh>   // Description of variables 
#include <DL_ErrorHandling.mqh> // Error library
#include <DL_PreChecks.mqh> // Prechecks
#include <DL_CheckOperationHours.mqh> // 
#include <Trade\Trade.mqh>
#include <A_PositionsManager.mqh>    // Scan for opened positions
#include <A_HistoryChecker.mqh> //Check transaction history
#include <A_TradeManager.mqh> //Manage trade dynamic open and close conditions
#include <A_EntriesManagement.mqh> // Check buy and sell entries signals and execute them
#include <A_LotSizeCal.mqh>   // Lot size calculate
//#include <DL_TradingBoundaries.mqh>  //Draw trading range boundaries on chart
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//Zigzag drawing inputs
string prefix = "SRLevel_";      //Object name prefix
color  lineColor = clrYellow;
int lineWeight = 2;

double SRLevels[];
double Buffer[];
int Handle;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Handle = iCustom(Symb, PERIOD_CURRENT, "Examples\\ZigZag", Depth, Deviation, Backstep);
   if(Handle==INVALID_HANDLE)
     {
      Print("Could not create a handle to ZigZag indicator");
      return(INIT_FAILED);
     }

//Clean up any SR levels left from earlier indicators
   ObjectsDeleteAll(0, prefix, 0, OBJ_HLINE);
   ChartRedraw(0);
   ArrayResize(SRLevels, LookBack);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(Handle);
   ObjectsDeleteAll(0, prefix, 0, OBJ_HLINE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ArraySetAsSeries(Buffer,true);

   CopyBuffer(Handle, 0, 0, 3, Buffer);
   if(candleChanged())
      if(Buffer[0]>0)
         Print("Zigzag level ", Buffer[0]);
//DrawLevels();

SymbolInfoTick(_Symbol,last_tick);

   if(!ScanPositions())
      return;

   CheckHistory();
   CheckSpread();
   EvaluateEntry();
   ProfitRunner();
   CloseOpenPositions();
   ExecuteEntry();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
/*
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//One time convert points to a price gap
   static double levelGap = GapPoint*SymbolInfoDouble(Symb, SYMBOL_POINT);

   if(rates_total ==prev_calculated)
      return(rates_total);

//Get most recent lookback peaks
   double zz =0;
   double zzPeaks[];
   int zzCount = 0;

   ArrayResize(zzPeaks, LookBack);
   ArrayInitialize(zzPeaks, 0.0);

   int count = CopyBuffer(Handle, 0, 0, rates_total, Buffer);

   if(count < 0)
     {
      int err = GetLastError();
      return(0);
     }

   for(int i=1; i<rates_total && zzCount<LookBack; i++)
     {
      zz = Buffer[i];
      Print(Buffer[i]);
      if(zz != 0 && zz != EMPTY_VALUE)
        {
         zzPeaks[zzCount] = zz;
         zzCount++;
        }
     }
   ArraySort(zzPeaks);

//Search for grouping and set levels
   int srCounter =0;         //Number of support and resistance found
   double price =0;          //Average peaks price
   int priceCount =0;        //How many peaks are found
   ArrayInitialize(SRLevels, 0.0);

   for(int i=LookBack-1; i>=0; i--)
     {
      price += zzPeaks[i];
      priceCount++;
      if(i=0 || (zzPeaks[i]-zzPeaks[i-1]) > GapPoint)
        {
         if(priceCount >= Sensitivity)
           {
            price = price/priceCount;
            SRLevels[srCounter] = price;
            srCounter++;
           }
         price =0;
         priceCount=0;
        }
     }
   DrawLevels();
//--- return value of prev_calculated for next call
   return(rates_total);
  }

*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLevels()
  {

   for(int i=0; i<LookBack; i++)
     {

      string name = "prefix_" + IntegerToString(i);
      Print("Drawing SR Lookback ", LookBack, " Find object ", ObjectFind(0, name), " SRLevel ", i, " ", SRLevels[i]);

      if(SRLevels[i] == 0)
        {
         ObjectDelete(0, name);
         continue;
        }

      Print("Peak ", SRLevels[i], " numero ", i);
      if(ObjectFind(0, name) < 0)
        {
         ObjectCreate(0,name, OBJ_HLINE, 0, 0, SRLevels[i]);
         ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, lineWeight);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
         ObjectMove(0, name, 0, iTime(Symb,_Period,0), SRLevels[i]);
        }
      else
        {
         ObjectSetDouble(0, name, OBJPROP_PRICE, SRLevels[1]);
        }
     }

   ChartRedraw(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool candleChanged()
  {
   MqlRates priceData[];
   ArraySetAsSeries(priceData, true);
   CopyRates(Symb, PERIOD_CURRENT, 0, 3, priceData);

   static datetime timeStampLastCheck;
   static int candleCounter;
   datetime timeStampCurrentCandle;

   timeStampCurrentCandle = priceData[0].time;

   if(timeStampCurrentCandle != timeStampLastCheck)
     {
      timeStampLastCheck = timeStampCurrentCandle;

      candleCounter = candleCounter+1;
      return true;
     }

   return false;
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
   double SpreadCurr=SymbolInfoInteger(Symb, SYMBOL_SPREAD);
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
