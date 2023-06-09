//+------------------------------------------------------------------+
//|                                                   AsianBreak.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

input int MaxCandleIteration=50;     //Max candles to check for trading range boundaries
input string AsianStart="22:00";                                 //Trading Boundary Hour
input string AsianEnd="07:00";                                  //Trading Boundary minute
input double   rangemargin=0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

double newHigh, newLow;
bool rangeUpdated = false;
double High[];
double Low[];
string server_time;
double upper_boundary, lower_boundary;    //Trading range boundaries
long   current_chart_id = ChartID();
int asianStartIndex, asianEndIndex;


//+------------------------------------------------------------------+
//|                                                                  |
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
//Get asian high and low
   drawRange();
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawRange()
  {
   string candles_times, candles_date, todayi;
   int    time_to_string, date_to_string;
   ushort a, b;
   string d_time = TimeToString(iTime(Symbol(),PERIOD_M30,0), TIME_MINUTES);
   string open_hour[];
   string obj_name = "Upper boundary", obj_name_l = "Lower boundary";

   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,_Period,0,MaxCandleIteration,High);

   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,_Period,0,MaxCandleIteration,Low);

//--- Get the separator code
   a = StringGetCharacter(":",0);
   b = StringGetCharacter(".",0);

   todayi = TimeToString(iTime(Symbol(),_Period,0), TIME_DATE);

   int k = StringSplit(d_time, a, open_hour);

   if(k>0)
     {
      server_time = "Server time on last 5 Min candle => Hour = " +open_hour[0]+ ", Minute = " +open_hour[1];
     }

// Get trading range
   for(int j = 0; j <= MaxCandleIteration; j++)
     {
      Print("Index ", j);
      string result[], datei[];
      candles_times = TimeToString(iTime(Symbol(),_Period,j), TIME_MINUTES);
      candles_date = TimeToString(iTime(Symbol(),_Period,j), TIME_DATE);
      date_to_string = StringSplit(candles_date, b, datei);
      time_to_string = StringSplit(candles_times, a, result);
      Print("date_to_string ", datei[0], " ", datei[1], " ", datei[2]);
      Print(candles_times, " ", iTime(Symbol(),_Period,j), " date ", candles_date);
      Print("Is trading boundary "+(result[0] == AsianStart && result[1] == AsianEnd));

      if(candles_times == AsianStart)
        {
         asianStartIndex = j;
         break;
        }
      if(candles_times == AsianEnd && todayi == candles_date)
        {
         asianEndIndex = j;
        }
      //ObjectDelete(current_chart_id, obj_name_l);
      //ObjectDelete(current_chart_id, obj_name);
      //In_Trade = false;
     }

   Print("Endindex ", asianEndIndex, "Startindex", asianStartIndex);

   double val, valo;
   int val_indexw;
//--- Calculation of the highest Close value among 20 consecutive bars
//--- From index 4 to index 23 inclusive, on the current timeframe
   int val_index=iHighest(NULL,0,MODE_HIGH,asianStartIndex+1,asianStartIndex);
   if(val_index!=-1)
      val=High[val_index];
   else
      PrintFormat("iHighest() call error. Error code=%d",GetLastError());

   if(asianEndIndex == 0)
     {
      val_indexw=iLowest(NULL,0,MODE_LOW,asianStartIndex-1,0);
      if(val_indexw!=-1)
         valo=Low[val_indexw];
      else
         PrintFormat("iHighest() call error. Error code=%d",GetLastError());
     }
   else
     {
      val_indexw=iLowest(NULL,0,MODE_LOW,10,asianEndIndex);
      if(val_indexw!=-1)
         valo=Low[val_indexw];
      else
         PrintFormat("iHighest() call error. Error code=%d",GetLastError());
     }

   Print("val ", val, " valo", valo);
   Print(iTime(Symbol(),_Period,asianEndIndex));
   Print(iTime(Symbol(),_Period,asianStartIndex));

   if(!rangeUpdated)
     {
      upper_boundary = val + rangemargin;
      lower_boundary = valo - rangemargin;
     }

   Print("upper_boundary ", upper_boundary, "lower_boundary ", lower_boundary);
//Print("Iteration no "+iTime(Symb,PERIOD_M5,j));
   ObjectCreate(current_chart_id, obj_name, OBJ_HLINE, 0, iTime(Symbol(),_Period,0), upper_boundary);

//--- set color to Red
   ObjectSetInteger(current_chart_id, obj_name, OBJPROP_COLOR, clrRed);
//--- set object width
   ObjectSetInteger(current_chart_id, obj_name, OBJPROP_WIDTH, 2);
//--- Move the line
   ObjectMove(current_chart_id, obj_name, 0, iTime(Symbol(),_Period,0), upper_boundary);

   ObjectCreate(current_chart_id, obj_name_l, OBJ_HLINE, 0, iTime(Symbol(),_Period,0), lower_boundary);

//--- set color to Red
   ObjectSetInteger(current_chart_id, obj_name_l, OBJPROP_COLOR, clrRed);
//--- set object width
   ObjectSetInteger(current_chart_id, obj_name_l, OBJPROP_WIDTH, 2);
//--- Move the line
   ObjectMove(current_chart_id, obj_name_l, 0, iTime(Symbol(),_Period,0), lower_boundary);


//Print("upper_boundary ", upper_boundary, " lower_boundary ", lower_boundary);
//Print("Real high ", iHigh(Symb, PERIOD_M5, j), " Real low ", iLow(Symb, PERIOD_M5, j), " as of ", TimeToString(iTime(Symb,PERIOD_M5, j)));

  }
//+------------------------------------------------------------------+
