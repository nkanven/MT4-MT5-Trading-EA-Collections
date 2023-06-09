//+------------------------------------------------------------------+
//|                                                   Dam Launch.mq5 |
//|                       Copyright 2021, Nkondog Anselme Venceslas. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------

#include <DL_InitMQL4.mqh> // Initialize MQL4 missing parameters
#include <DL_Parameters.mqh>   // Description of variables 
#include <DL_ErrorHandling.mqh> // Error library
#include <DL_PreChecks.mqh> // Prechecks
#include <DL_CheckOperationHours.mqh> // 
#include <Trade\Trade.mqh>
#include <DL_CheckHistory.mqh> //Check transaction history
#include <DL_TradeManagement.mqh>
#include <DL_EntriesManagement.mqh> // Check buy and sell entries signals and execute them
#include <DL_LotSizeCal.mqh>   // Lot size calculate
#include <DL_TradingBoundaries.mqh>  //Draw trading range boundaries on chart
#include <DL_ScanPositions.mqh>    // Scan for opened positions
#include <DL_ClosePositions.mqh>   // Close opened positions
#include <Logger.mqh>
//--- initialize a logger
void InitLogger()
  {
//--- set logging levels: 
//--- DEBUG-level for writing messages in a log file
//--- ERROR-level for notifications
   CLogger::SetLevels(LOG_LEVEL_WARNING,LOG_LEVEL_ERROR);
//--- set a logging method as an external file writing
   CLogger::SetLoggingMethod(LOGGING_OUTPUT_METHOD_EXTERN_FILE);
//--- set a notification type as PUSH notifications
   CLogger::SetNotificationMethod(NOTIFICATION_METHOD_PUSH);
//--- set a name for log files
   CLogger::SetLogFileName("my_log");
//--- set log file restrictions as "new log file for every new day"
   CLogger::SetLogFileLimitType(LOG_FILE_LIMIT_TYPE_ONE_DAY);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   /*InitLogger();
   CLogger::Add(LOG_LEVEL_INFO,"");
   CLogger::Add(LOG_LEVEL_INFO,"---------- OnInit() -----------");
   LOG(LOG_LEVEL_DEBUG,"Example of debug message");
   LOG(LOG_LEVEL_INFO,"Example of info message");
   LOG(LOG_LEVEL_WARNING,"Example of warning message");
   LOG(LOG_LEVEL_ERROR,"Example of error message");
   LOG(LOG_LEVEL_FATAL,"Example of fatal message");*/
//---
//It is useful to set a function to check the integrity of the initial parameters and call it as first thing
      CheckPreChecks();
   //If the initial pre checks have something wrong, stop the program
      if(!IsPreChecksOk)
        {
        Print("Precheck failed");
         OnDeinit(INIT_FAILED);
         return(INIT_FAILED);
        }
   //Function to initialize the values of the global variables
   InitializeVariables();

   Print("Successfull initialization");

//If everything is ok the function returns successfully and the control is passed to a timer or the OnTick function
   return(INIT_SUCCEEDED);
//---
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
   datetime ht = TimeCurrent();
   TimeToStruct(ht, dt);

   printf("On tick--------------------------- on "+dt.hour);
   SymbolInfoTick(_Symbol,last_tick);
//Re-initialize the values of the global variables at every run
   InitializeVariables();

   CloseOpenPositions();
//ScanPositions scans all the opened positions and collect statistics, if an error occurs it skips to the next price change
   if(!ScanPositions())
      return;
//CheckNewBar checks if the price change happened at the start of a new bar
//CheckNewBar();
//CheckOperationHours checks if the current time is in the operating hours
   CheckOperationHours();
//CheckSpread checks if the spread is above the maximum spread allowed
   CheckSpread();
//CheckTradedThisBar checks if there was already a trade executed in the current candle
   CheckTradedThisBar();

//EvaluateExit contains the code to decide if there is an exit signal
//EvaluateExit();
//ExecuteExit executes the exit in case there is an exit signal
//ExecuteExit();
CheckHistory();
//Scan positions again in case some where closed, if an error occurs it skips to the next price change
   if(!ScanPositions())
      return;

//Draw trading range
   drawRange();
   
//EvaluateEntry contains the code to decide if there is an entry signal
   EvaluateEntry();
   Print("SignalEntry status ", SignalEntry);

//ExecuteEntry executes the entry in case there is an entry signal
   ExecuteEntry();
//CloseOpenPositions();


   Comment(
      "Expert Advisor by Anselme Nkondog (c) 2021\n");
   return;                             // Exit start()
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

//Check if there was already an order open this bar
void CheckTradedThisBar()
  {
//LastBarTraded contains the open time the last trade
//if that open time is in the same bar as the current then IsTradedThisBar is true
   if(iBarShift(Symbol(),PERIOD_CURRENT,LastBarTraded)==0)
      IsTradedThisBar=true;
   else
      IsTradedThisBar=false;
  }

//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   int SpreadCurr=(int)Spread;
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
