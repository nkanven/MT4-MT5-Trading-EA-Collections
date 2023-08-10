//+------------------------------------------------------------------+
//|                                                    Salixmiku.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Indicators/Trend.mqh>
#include <Nkanven\DL_ErrorHandling.mqh> // Error library
#include <Nkanven\Salimoku\parameters.mqh>   // Description of variables 
#include <Nkanven\Salimoku\openTrades.mqh>   // Trade manager
#include <Nkanven\Salimoku\positionScaner.mqh>   // Trade manager
#include <Nkanven\DL_LotSizeCal.mqh>   // Lot size calculate

CiIchimoku* ichimoku;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  //---
   ichimoku = new CiIchimoku();
   ichimoku.Create(Symb, PERIOD_CURRENT, tenkan_sen, kijun_sen, senkou_span_b);

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
   
   ScanPositions();
   tradeSignal();
   Print("Trade signal ", SignalEntry);
   ExecuteEntry();
  }
//+------------------------------------------------------------------+

void tradeSignal(){

   ichimoku.Refresh(-1);
   SignalEntry = SIGNAL_EXIT_NEUTRAL;
   
   Tenkansen = ichimoku.TenkanSen(0);
   Kijunsen = ichimoku.KijunSen(0);
   signal_tenkan = ichimoku.TenkanSen(3);
   signal_kijun = ichimoku.KijunSen(3);
   
   close_1 = iClose(Symbol(), PERIOD_CURRENT, 1);
   close_2 = iClose(Symbol(), PERIOD_CURRENT, 2);
   close_3 = iClose(Symbol(), PERIOD_CURRENT, 3);
   open_1 = iOpen(Symbol(), PERIOD_CURRENT, 1);
   open_2 = iOpen(Symbol(), PERIOD_CURRENT, 2);
   open_3 = iOpen(Symbol(), PERIOD_CURRENT, 3);
   high_3 = iHigh(Symbol(), PERIOD_CURRENT, 3);
   
   //Short position
   //Kijun below Tenkan
   if(signal_kijun <= signal_tenkan)
     {
      //We have 2 bearish candles aligned
      if(close_1 < open_1 && close_2 < open_2 && close_3 < open_3)
        {
         //Close_3 break through Kijun/Tenkan
         if(high_3 > signal_kijun && close_3 < signal_kijun)
           {
               SignalEntry = SIGNAL_ENTRY_SELL;
           }
         
        }
     }
     
    //Long position
   //Kijun above Tenkan
   if(signal_kijun >= signal_tenkan)
     {
      //We have 3 bullish candles aligned
      if(close_1 > open_1 && close_2 > open_2 && close_3 > open_3)
        {
         //Close_3 break through Kijun/Tenkan
         if(high_3 > signal_kijun && close_3 > signal_kijun)
           {
               SignalEntry = SIGNAL_ENTRY_BUY;
           }
         
        }
     }
}
