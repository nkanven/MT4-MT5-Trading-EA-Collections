//+------------------------------------------------------------------+
//|                                                       LoggerTest |
//|                                           Sergey Eryomin (ENSED) |
//|                                                 sergey@ensed.org |
//+------------------------------------------------------------------+
#property copyright "Sergey Eryomin"
#property link      "http://ensed.org"

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
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   InitLogger();
   CLogger::Add(LOG_LEVEL_INFO,"");
   CLogger::Add(LOG_LEVEL_INFO,"---------- OnInit() -----------");
   LOG(LOG_LEVEL_DEBUG,"Example of debug message");
   LOG(LOG_LEVEL_INFO,"Example of info message");
   LOG(LOG_LEVEL_WARNING,"Example of warning message");
   LOG(LOG_LEVEL_ERROR,"Example of error message");
   LOG(LOG_LEVEL_FATAL,"Example of fatal message");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+------------------------------------------------------------------+
