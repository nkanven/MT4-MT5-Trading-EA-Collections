//+------------------------------------------------------------------+
//|                                                MidNightAngel.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Nkanven\MidNightAngel\Parameters.mqh>   // Description of variables 
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
//---
   datetime ht = TimeCurrent();
   TimeToStruct(ht, dt);

   printf("On tick--------------------------- on "+dt.hour);
   SymbolInfoTick(_Symbol,last_tick);
storeEquity();
HasTodayClosingPosition();
   if(FileIsExist(filename))
     {
      //Compare stored balance and actual balance
      if(getStoredBalance() > AccountInfoDouble(ACCOUNT_BALANCE))
        {
         IsLosing=true;
        }
      else
        {
         IsLosing=false;
        }
     }
   else
     {
      storeEquity();
     }

   if(dt.hour == 0)
     {
     if(PositionsTotal()==0 && !HasTodayClosingPosition())
       {
         if(IsLosing)
          {
           
          }
       }
      }
 Comment("Periode d", PeriodSeconds(PERIOD_D1) , "Hour is true", " Balance is actually = ", AccountInfoInteger(ACCOUNT_LOGIN), " File ", FileIsExist(filename));

//if file exist
   //get isLosing
//else store balance

//Verify trading time
      //if no opened position or daily closed position
         //if isLosing
            //if 1 loss -> InpOneSlSize
            //if 2 losses -> InpTwoSlSize
      //else place x1 buy trade

   //if equity > storeEquity -> update storeEquity
  }
//+------------------------------------------------------------------+

//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   long SpreadCurr=(int)Spread;
   Print("Spread ", SpreadCurr);
   if(SpreadCurr<=InpMaxSpread)
     {
      IsSpreadOK=true;
     }
   else
     {
      IsSpreadOK=false;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void storeEquity()
  {

   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
   printf(" terminal_data_path ", terminal_data_path);
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT,",");
   if(filehandle!=INVALID_HANDLE)
     {
      FileWrite(filehandle,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)));
      FileClose(filehandle);
      //Print("The file must be created in the folder "+terminal_data_path+"\\"+subfolder);
     }
   else
      Print("File open failed, error ",GetLastError());

  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getStoredBalance()
  {
   int balance;
   struct Table
     {
      int            line;
      datetime       date;
      string         symbol;
      double         price;

     };

   Table table[];

   int i=0;

   short delimiter=',';
   int fileHandle = FileOpen(filename,FILE_READ|FILE_ANSI,delimiter);

   if(fileHandle==INVALID_HANDLE)
      Alert("could not open file, error: "+(string)GetLastError());

   if(fileHandle!=INVALID_HANDLE)
     {
      while(FileIsEnding(fileHandle) == false)
        {


         ArrayResize(table,ArraySize(table) +1);
         table[i].line = (int) FileReadNumber(fileHandle);
         /* table[i].date = FileReadDatetime(fileHandle);
          table[i].symbol = FileReadString(fileHandle);
          table[i].price = FileReadNumber(fileHandle);*/
         i++;

        }

      FileClose(fileHandle);

     }
   for(i=0; i<ArraySize(table); i++)
     {
      balance = table[i].line;
     }

   return balance;
  }
//+------------------------------------------------------------------+

bool HasTodayClosingPosition()
{
   ulong    ticket=0;
   double   profit;
   datetime time;
   string   symbol;
   long     type;
   long     entry;

   datetime timeStart = TimeCurrent() - PeriodSeconds(PERIOD_D1);
   
   printf(TimeToString(timeStart));
   HistorySelect(timeStart,TimeCurrent());
   uint     total=HistoryDealsTotal();

   Print("Total deal in history ", total);
      if(total > 0)
        {
         return true;
        } else
            {
             return false;
            }
}