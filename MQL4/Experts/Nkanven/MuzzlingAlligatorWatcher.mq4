//+------------------------------------------------------------------+
//|                                     MuzzlingAlligatorWatcher.mq4 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "ttps://www.linkedin.com/in/nkondog"
#property version   "1.00"
#property strict

#include <Nkanven/Lib/Navlib.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input string Comment_0="==========";                     //Alligator parameters
input ENUM_TIMEFRAMES inpTimeframe = PERIOD_CURRENT;     //Timeframe
input int inpJawsPeriod = 13;                            //Jaws period
input int inpJawsShift = 8;                              //Jaws shift
input int inpTeethPeriod = 8;                            //Teeth period
input int inpTeethShift = 5;                             //Teeth shift
input int inpLipsPeriod = 5;                             //Lips period
input int inpLipsShift = 3;                              //Lips shift
input ENUM_MA_METHOD inpMethod = MODE_SMMA;              //Method
input ENUM_APPLIED_PRICE inpApplyedTo = PRICE_MEDIAN;    //Applied to

input string Comment_1="==========";                     //Moving average parameters
input ENUM_MA_METHOD inpMAMethod = MODE_SMA;             //MA method
input int inpMAPeriod = 200;                               //MA period
input int inpMASHift = 0;                                //MA shift
input ENUM_APPLIED_PRICE inpMAApplyedTo = PRICE_CLOSE;   //MA applied to

double jaws, teeth, lips, sma, prevCandleHigh, prevCandleLow, currentPrice, candleClose;
string comm = "";

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
   if(!newCandle())
     return;

   jaws=iAlligator(NULL,0,inpJawsPeriod,inpJawsShift,inpTeethPeriod,inpTeethShift,inpLipsPeriod,inpLipsShift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,0);
   teeth=iAlligator(NULL,0,inpJawsPeriod,inpJawsShift,inpTeethPeriod,inpTeethShift,inpLipsPeriod,inpLipsShift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,0);
   lips=iAlligator(NULL,0,inpJawsPeriod,inpJawsShift,inpTeethPeriod,inpTeethShift,inpLipsPeriod,inpLipsShift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,0);
   
   sma = iMA(NULL,0,inpMAPeriod,inpMASHift,inpMAMethod,inpMAApplyedTo,1);
   Print(" Jaws ", jaws, " teeth ", teeth, " lips ", lips, " sma ", sma);
   
   //Get previous candle
   prevCandleHigh = iHigh(NULL, PERIOD_CURRENT, 1);
   prevCandleLow = iLow(NULL, PERIOD_CURRENT, 1);
   currentPrice = iClose(NULL, PERIOD_CURRENT, 0);
   candleClose = iLow(NULL, PERIOD_CURRENT, 0);

//comm = "jaws " + (string)jaws + " teeth " + (string)teeth + " lips " + (string)lips + " sma " + (string)sma;
   comm = "Trade alert on " + Symbol();
   comm += "\n";
   comm += "";

   if(sma < currentPrice)
     {
      //Alert for bullish continuation signal
      if(prevCandleHigh > jaws && prevCandleHigh > teeth && prevCandleHigh > lips)
        {
         if(prevCandleLow < jaws || prevCandleLow < teeth ||prevCandleLow < lips)
           {
            comm += "LONG CONTINUATION SIGNAL: Price above SMA just moves above Alligator. \n";
            Notify(comm);
           }
        }

      //Alert for bearish counter trend signal
      if(lips > teeth && teeth > jaws)
        {

         if(candleClose < lips && candleClose < teeth && candleClose < jaws)
           {
            comm += " SHORT COUNTER TREND SIGNAL: Price above SMA moves below Alligator in a trending market \n";
            Notify(comm);
           }
        }
     }


   if(sma > currentPrice)
     {
      //Alert for bearish continuation signal
      if(prevCandleLow < jaws && prevCandleLow < teeth && prevCandleLow < lips)
        {
         if(prevCandleHigh > jaws || prevCandleHigh > teeth ||prevCandleHigh > lips)
           {
            comm += " SHORT CONTINUATION SIGNAL: Price below SMA just moves below Alligator.  \n";
            Notify(comm);
           }
        }

      //Alert for bearish counter trend signal
      if(lips < teeth && teeth < jaws)
        {

         if(candleClose > lips && candleClose > teeth && candleClose > jaws)
           {
            comm += " LONG COUNTER TREND SIGNAL: Price below SMA just closes above Alligator in a down trending market \n";
            Notify(comm);
           }
        }
     }
  }
//+------------------------------------------------------------------+
