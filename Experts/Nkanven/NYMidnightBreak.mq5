//+------------------------------------------------------------------+
//|                                              NYMidnightBreak.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Nkanven\NYMidnightBreak\Parameters.mqh>   // EA paramters
#include <Nkanven\NYMidnightBreak\LotSizeCal.mqh>   // Lot size calculator

#define SECONDSINADAY  86400
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
//--- The date is on Sunday 
   datetime time=D'2002.04.25 12:00'; 
   string symbol="GBPUSD"; 
   ENUM_TIMEFRAMES tf=PERIOD_H1; 
   bool exact=false; 
//--- If there is no bar at the specified time, iBarShift will return the index of the nearest bar 
   int bar_index=iBarShift(symbol,tf,time,exact); 
//--- Check the error code after the call of iBarShift() 

datetime Midnight, StartOfNewYear;
   

   Midnight = TimeCurrent() - ( TimeCurrent()%SECONDSINADAY );  // midnight today as a datetime
   Print(" Hour ", dt.hour, " midnight " , Midnight);
  }
//+------------------------------------------------------------------+
