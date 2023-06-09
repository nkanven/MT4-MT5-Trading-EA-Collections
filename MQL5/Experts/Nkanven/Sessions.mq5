//+------------------------------------------------------------------+
//|                                                     Sessions.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input int    NumberOfDays = 50;        // Êîëè÷åñòâî äíåé
input string AsiaBegin    = "01:00";   // Îòêðûòèå àçèàòñêîé ñåññèè
input string AsiaEnd      = "10:00";   // Çàêðûòèå àçèàòñêîé ñåññèè
input color  AsiaColor    = Goldenrod; // Öâåò àçèàòñêîé ñåññèè
input string EurBegin     = "07:00";   // Îòêðûòèå åâðîïåéñêîé ñåññèè
input string EurEnd       = "16:00";   // Çàêðûòèå åâðîïåéñêîé ñåññèè
input color  EurColor     = Tan;       // Öâåò åâðîïåéñêîé ñåññèè
input string USABegin     = "14:00";   // Îòêðûòèå àìåðèêàíñêîé ñåññèè
input string USAEnd       = "23:00";   // Çàêðûòèå àìåðèêàíñêîé ñåññèè
input color  USAColor     = PaleGreen; // Öâåò àìåðèêàíñêîé ñåññèè

int OnInit()
  {
//---
   DeleteObjects();
   for(int i=0; i<NumberOfDays; i++)
     {
      CreateObjects("AS"+i, AsiaColor);
      CreateObjects("EU"+i, EurColor);
      CreateObjects("US"+i, USAColor);
     }
   Comment("");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   DeleteObjects();
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   datetime dt=TimeCurrent();

   for(int i=0; i<NumberOfDays; i++)
     {
      DrawObjects(dt, "AS"+i, AsiaBegin, AsiaEnd);
      DrawObjects(dt, "EU"+i, EurBegin, EurEnd);
      DrawObjects(dt, "US"+i, USABegin, USAEnd);
      dt=decDateTradeDay(dt);
      while(TimeDayOfWeekMQL4(dt)>5)
         dt=decDateTradeDay(dt);
     }
  }
//+------------------------------------------------------------------+
void CreateObjects(string no, color cl)
  {
   ObjectCreate(0, no, OBJ_RECTANGLE, 0, 0,0, 0,0);
   ObjectSetInteger(0, no, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, no, OBJPROP_COLOR, cl);
   ObjectSetInteger(0, no, OBJPROP_BACK, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   for(int i=0; i<NumberOfDays; i++)
     {
      ObjectDelete(0, "AS"+i);
      ObjectDelete(0, "EU"+i);
      ObjectDelete(0, "US"+i);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawObjects(datetime dt, string no, string tb, string te)
  {
   datetime t1, t2;
   double   p1, p2;
   int      b1, b2;

   t1=StringToTime(TimeToString(dt, TIME_DATE)+" "+tb);
   t2=StringToTime(TimeToString(dt, TIME_DATE)+" "+te);
   b1=iBarShift(NULL, 0, t1);
   b2=iBarShift(NULL, 0, t2);
   p1=iHighest(NULL, 0, MODE_HIGH, b1-b2, b2);
   p2=iLowest(NULL, 0, MODE_LOW, b1-b2, b2);
   ObjectSetInteger(0, no, OBJPROP_TIME, t1);
   ObjectSetDouble(0, no, OBJPROP_PRICE, p1);
   ObjectSetInteger(0, no, OBJPROP_TIME, t2);
   ObjectSetDouble(0, no, OBJPROP_PRICE, p2);
  }
//+------------------------------------------------------------------+

datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StringToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}

int TimeDayOfWeekMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
  
  int TimeYear(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.year);
  }
  
  int TimeMonth(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.mon);
  }
  
  int TimeMinute(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.min);
  }
  
  int TimeHour(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.hour);
  }
  
  int TimeDay(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_year);
  }