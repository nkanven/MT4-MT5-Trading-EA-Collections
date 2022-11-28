//+------------------------------------------------------------------+
//|                                     MuzzlingAlligatorWatcher.mq5 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin.com/in/nkondog"
#property version   "1.00"

#include <Indicators/BillWilliams.mqh>
#include <Indicators/Trend.mqh>
#include <Libraries/NavLib.mq5>

CiAlligator* alligator;
CiMA* ma;

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


double jaws, teeth, lips, sma, prevCandleHigh, prevCandleLow, currentPrice, openPrice, candleClose;
string symb = Symbol();
string comm = "";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   alligator = new CiAlligator();
   alligator.Create(symb, inpTimeframe, inpJawsPeriod, inpJawsShift, inpTeethPeriod, inpTeethShift, inpLipsPeriod, inpLipsShift, inpMethod, inpApplyedTo);

   ma = new CiMA();
   ma.Create(symb, inpTimeframe, inpMAPeriod, inpMASHift, inpMAMethod, inpMAApplyedTo);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   ObjectsDeleteAll(0);
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//Alligator variables initialization
   alligator.Refresh(-1);
   jaws = NormalizeDouble(alligator.Jaw(0), _Digits);
   teeth = NormalizeDouble(alligator.Teeth(0), _Digits);
   lips = NormalizeDouble(alligator.Lips(0), _Digits);

//Moving Average variable initialization
   ma.Refresh(-1);
   sma = NormalizeDouble(ma.Main(1), _Digits);

//Get previous candle
   prevCandleHigh = iHigh(symb, PERIOD_CURRENT, 1);
   prevCandleLow = iLow(symb, PERIOD_CURRENT, 1);
   currentPrice = iClose(symb, PERIOD_CURRENT, 0);
   candleClose = iLow(symb, PERIOD_CURRENT, 0);

//comm = "jaws " + (string)jaws + " teeth " + (string)teeth + " lips " + (string)lips + " sma " + (string)sma;
   comm = "Trade alert on " + symb;
   comm += "\n";
   comm += "";
   
   Notify(comm);


   if(sma < currentPrice)
     {
      //Alert for bullish continuation signal
      if(prevCandleHigh > jaws && prevCandleHigh > teeth && prevCandleHigh > lips)
        {
         if(prevCandleLow < jaws || prevCandleLow < teeth ||prevCandleLow < lips)
           {
            comm += "LONG CONTINUATION SIGNAL: Price above SMA just moves above Alligator. \n";
           }
        }

      //Alert for bearish counter trend signal
      if(lips > teeth && teeth > jaws)
        {

         if(candleClose < lips && candleClose < teeth && candleClose < jaws)
           {
            comm += "SHORT COUNTER TREND SIGNAL: Price above SMA moves below Alligator in a trending market \n";
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
            comm += "SHORT CONTINUATION SIGNAL: Price below SMA just moves below Alligator.  \n";
           }
        }

      //Alert for bearish counter trend signal
      if(lips < teeth && teeth < jaws)
        {

         if(candleClose > lips && candleClose > teeth && candleClose > jaws)
           {
            comm += "LONG COUNTER TREND SIGNAL: Price below SMA just closes above Alligator in a down trending market \n";
           }
        }
     }

   if(MQLInfoInteger(MQL_TESTER))
     {
      Comment(comm);
     }
   else
     {
      Notify(comm);
     }

  }

//+------------------------------------------------------------------+
void Notify(string message)
  {
Print("Message sent ", message);
   //SendNotification(message);

   string  headers;
   string  url = "https://api.telegram.org/bot5854676759:AAEGN1a1HQ-3uiVtv7FxEf7IXKrMATBzkQg/sendMessage?chat_id=-1001821417162&text="+message;
   char    data[],result[];

   int res = WebRequest("GET",
                        url,
                        NULL,
                        NULL,
                        3000,
                        data,
                        0,
                        result,
                        headers
                       );
Print(CharArrayToString(result), " Res ", res, headers);       // see the results

   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      MessageBox("Add the address '"+url+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      if(res==200)
        {
         //--- Successful download
         Print("Telegran notification sent.");
        }
     }
  }
//+------------------------------------------------------------------+
