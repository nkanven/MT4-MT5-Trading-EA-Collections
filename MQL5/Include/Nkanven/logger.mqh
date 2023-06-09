//+------------------------------------------------------------------+
//|                                                       logger.mqh |
//|                                   Copyright 2015, Sergey Eryomin |
//|                                             http://www.ensed.org |
//+------------------------------------------------------------------+
#property copyright "Sergey Eryomin"
#property link      "http://www.ensed.org"

#define LOG(level, message) CLogger::Add(level, message+" ("+__FILE__+"; "+__FUNCSIG__+"; Line: "+(string)__LINE__+")")
//--- maximum number of files for operation of "a new log file for each new 1 Mb"
#define MAX_LOG_FILE_COUNTER (100000) 
//--- number of bytes in a megabyte
#define BYTES_IN_MEGABYTE (1048576)
//--- maximum length of a log file's name
#define MAX_LOG_FILE_NAME_LENGTH (255)
//--- logging levels
enum ENUM_LOG_LEVEL
  {
   LOG_LEVEL_DEBUG,
   LOG_LEVEL_INFO,
   LOG_LEVEL_WARNING,
   LOG_LEVEL_ERROR,
   LOG_LEVEL_FATAL
  };
//--- logging methods
enum ENUM_LOGGING_METHOD
  {
   LOGGING_OUTPUT_METHOD_EXTERN_FILE,// external file
   LOGGING_OUTPUT_METHOD_PRINT // Print function
  };
//--- notification methods
enum ENUM_NOTIFICATION_METHOD
  {
   NOTIFICATION_METHOD_NONE,// disabled
   NOTIFICATION_METHOD_ALERT,// Alert function
   NOTIFICATION_METHOD_MAIL, // SendMail function
   NOTIFICATION_METHOD_PUSH // SendNotification function
  };
//--- log files restriction types
enum ENUM_LOG_FILE_LIMIT_TYPE
  {
   LOG_FILE_LIMIT_TYPE_ONE_DAY,// new log file for every new day
   LOG_FILE_LIMIT_TYPE_ONE_MEGABYTE // new log file for every new 1Mb
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLogger
  {
public:
   //--- add a message to the log
   //--- Note:
   //--- if output mode to external file is on but it can't be executed,
   //--- then message output is done via Print()
   static void Add(const ENUM_LOG_LEVEL level,const string message)
     {
      if(level>=m_logLevel)
        {
         Write(level,message);
        }

      if(level>=m_notifyLevel)
        {
         Notify(level,message);
        }
     }
   //--- set logging levels
   static void SetLevels(const ENUM_LOG_LEVEL logLevel,const ENUM_LOG_LEVEL notifyLevel)
     {
      m_logLevel=logLevel;
      //--- a level of message output via notifications shouldn't be below a level of writing messages in a log file
      m_notifyLevel=fmax(notifyLevel,m_logLevel);
     }
   //--- set a logging method
   static void SetLoggingMethod(const ENUM_LOGGING_METHOD loggingMethod)
     {
      m_loggingMethod=loggingMethod;
     }
   //--- set a notification method
   static void SetNotificationMethod(const ENUM_NOTIFICATION_METHOD notificationMethod)
     {
      m_notificationMethod=notificationMethod;
     }
   //--- set a name for a log file
   static void SetLogFileName(const string logFileName)
     {
      m_logFileName=logFileName;
     }
   //--- set a type of restriction for a log file
   static void SetLogFileLimitType(const ENUM_LOG_FILE_LIMIT_TYPE logFileLimitType)
     {
      m_logFileLimitType=logFileLimitType;
     }

private:
   //--- messages with this and higher logging level will be stored in a log file/journal
   static ENUM_LOG_LEVEL m_logLevel;
   //--- messages with this and higher logging level will be written as notifications
   static ENUM_LOG_LEVEL m_notifyLevel;
   //--- logging method
   static ENUM_LOGGING_METHOD m_loggingMethod;
   //--- notification method
   static ENUM_NOTIFICATION_METHOD m_notificationMethod;
   //--- name of log file
   static string     m_logFileName;
   //--- type of restriction for a log file
   static ENUM_LOG_FILE_LIMIT_TYPE m_logFileLimitType;
   //---a result of getting a file name for a log           
   struct GettingFileLogNameResult
     {
                        GettingFileLogNameResult(void)
        {
         succes=false;
         ArrayInitialize(value,0);
        }
      bool              succes;
      char              value[MAX_LOG_FILE_NAME_LENGTH];
     };
   //--- a result for checking the size of existing log file
   enum ENUM_LOG_FILE_SIZE_CHECKING_RESULT
     {
      IS_LOG_FILE_LESS_ONE_MEGABYTE,
      IS_LOG_FILE_NOT_LESS_ONE_MEGABYTE,
      LOG_FILE_SIZE_CHECKING_ERROR
     };
   //--- write in a log file
   static void Write(const ENUM_LOG_LEVEL level,const string message)
     {
      switch(m_loggingMethod)
        {
         case LOGGING_OUTPUT_METHOD_EXTERN_FILE:
           {
            GettingFileLogNameResult getLogFileNameResult=GetLogFileName();
            //---
            if(getLogFileNameResult.succes)
              {
               string fileName=CharArrayToString(getLogFileNameResult.value);
               //---
               if(WriteToFile(fileName,GetDebugLevelStr(level)+": "+message))
                 {
                  break;
                 }
              }
           }
         case LOGGING_OUTPUT_METHOD_PRINT:
            default:
              {
               Print(GetDebugLevelStr(level)+": "+message);
               break;
              }
        }
     }
   //--- execute a notification
   static void Notify(const ENUM_LOG_LEVEL level,const string message)
     {
      if(m_notificationMethod==NOTIFICATION_METHOD_NONE)
        {
         return;
        }
      string fullMessage=TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS)+", "+Symbol()+" ("+GetPeriodStr()+"), "+message;
      //---
      switch(m_notificationMethod)
        {
         case NOTIFICATION_METHOD_MAIL:
           {
            if(TerminalInfoInteger(TERMINAL_EMAIL_ENABLED))
              {
               if(SendMail("Logger",fullMessage))
                 {
                  return;
                 }
              }
           }
         case NOTIFICATION_METHOD_PUSH:
           {
            if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
              {
               if(SendNotification(fullMessage))
                 {
                  return;
                 }
              }
           }
        }
      //---
      Alert(GetDebugLevelStr(level)+": "+message);
     }
   //--- obtain a log file name for writing
   static GettingFileLogNameResult GetLogFileName()
     {
      if(m_logFileName=="")
        {
         InitializeDefaultLogFileName();
        }
      //---
      switch(m_logFileLimitType)
        {
         case LOG_FILE_LIMIT_TYPE_ONE_DAY:
           {
            return GetLogFileNameOnOneDayLimit();
           }
         case LOG_FILE_LIMIT_TYPE_ONE_MEGABYTE:
           {
            return GetLogFileNameOnOneMegabyteLimit();
           }
         default:
           {
            GettingFileLogNameResult failResult;
            failResult.succes=false;
            return failResult;
           }
        }
     }
   //--- get a log file name in case of restriction with "new log file for every new day"
   static GettingFileLogNameResult GetLogFileNameOnOneDayLimit()
     {
      GettingFileLogNameResult result;
      string fileName=m_logFileName+"_"+Symbol()+"_"+GetPeriodStr()+"_"+TimeToString(TimeLocal(),TIME_DATE);
      StringReplace(fileName,".","_");
      fileName=fileName+".log";
      result.succes=(StringToCharArray(fileName,result.value)==StringLen(fileName)+1);
      return result;
     }
   //--- get a log file name in case of restriction with "new log file for each new 1 Mb"
   static GettingFileLogNameResult GetLogFileNameOnOneMegabyteLimit()
     {
      GettingFileLogNameResult result;
      //---
      for(int i=0; i<MAX_LOG_FILE_COUNTER; i++)
        {
         ResetLastError();
         string fileNameToCheck=m_logFileName+"_"+Symbol()+"_"+GetPeriodStr()+"_"+(string)i;
         StringReplace(fileNameToCheck,".","_");
         fileNameToCheck=fileNameToCheck+".log";
         ResetLastError();
         bool isExists=FileIsExist(fileNameToCheck);
         //---
         if(!isExists)
           {
            if(GetLastError()==5018)
              {
               continue;
              }
           }
         //---
         if(!isExists)
           {
            result.succes=(StringToCharArray(fileNameToCheck,result.value)==StringLen(fileNameToCheck)+1);

            break;
           }
         else
           {
            ENUM_LOG_FILE_SIZE_CHECKING_RESULT checkLogFileSize=CheckLogFileSize(fileNameToCheck);

            if(checkLogFileSize==IS_LOG_FILE_LESS_ONE_MEGABYTE)
              {
               result.succes=(StringToCharArray(fileNameToCheck,result.value)==StringLen(fileNameToCheck)+1);

               break;
              }
            else if(checkLogFileSize!=IS_LOG_FILE_NOT_LESS_ONE_MEGABYTE)
              {
               break;
              }
           }
        }
      //---
      return result;
     }
   //---
   static ENUM_LOG_FILE_SIZE_CHECKING_RESULT CheckLogFileSize(const string fileNameToCheck)
     {
      int fileHandle=FileOpen(fileNameToCheck,FILE_TXT|FILE_READ);
      //---
      if(fileHandle==INVALID_HANDLE)
        {
         return LOG_FILE_SIZE_CHECKING_ERROR;
        }
      //---
      ResetLastError();
      ulong fileSize=FileSize(fileHandle);
      FileClose(fileHandle);
      //---
      if(GetLastError()!=0)
        {
         return LOG_FILE_SIZE_CHECKING_ERROR;
        }
      //---
      if(fileSize<BYTES_IN_MEGABYTE)
        {
         return IS_LOG_FILE_LESS_ONE_MEGABYTE;
        }
      else
        {
         return IS_LOG_FILE_NOT_LESS_ONE_MEGABYTE;
        }
     }
   //--- perform a log file name initialization by default
   static void InitializeDefaultLogFileName()
     {
      m_logFileName=MQLInfoString(MQL_PROGRAM_NAME);
      //---
#ifdef __MQL4__
      StringReplace(m_logFileName,".ex4","");
#endif

#ifdef __MQL5__
      StringReplace(m_logFileName,".ex5","");
#endif
     }
   //--- write a message in a file
   static bool WriteToFile(const string fileName,
                           const string text)
     {
      ResetLastError();
      string fullText=TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS)+", "+Symbol()+" ("+GetPeriodStr()+"), "+text;
      int fileHandle=FileOpen(fileName,FILE_TXT|FILE_READ|FILE_WRITE);
      bool result=true;
      //---
      if(fileHandle!=INVALID_HANDLE)
        {
         //--- attempt to place a file pointer in the end of a file            
         if(!FileSeek(fileHandle,0,SEEK_END))
           {
            Print("Logger: FileSeek() is failed, error #",GetLastError(),"; text = \"",fullText,"\"; fileName = \"",fileName,"\"");
            result=false;
           }
         //--- attempt to write a text in a file
         if(result)
           {
            if(FileWrite(fileHandle,fullText)==0)
              {
               Print("Logger: FileWrite() is failed, error #",GetLastError(),"; text = \"",fullText,"\"; fileName = \"",fileName,"\"");
               result=false;
              }
           }
         //---
         FileClose(fileHandle);
        }
      else
        {
         Print("Logger: FileOpen() is failed, error #",GetLastError(),"; text = \"",fullText,"\"; fileName = \"",fileName,"\"");
         result=false;
        }
      //---
      return result;
     }
   //--- get a current period as a line
   static string GetPeriodStr()
     {
      ResetLastError();
      string periodStr=EnumToString(Period());
      if(GetLastError()!=0)
        {
         periodStr=(string)Period();
        }
      StringReplace(periodStr,"PERIOD_","");
      //---
      return periodStr;
     }
   //---
   static string GetDebugLevelStr(const ENUM_LOG_LEVEL level)
     {
      ResetLastError();
      string levelStr=EnumToString(level);
      //---
      if(GetLastError()!=0)
        {
         levelStr=(string)level;
        }
      StringReplace(levelStr,"LOG_LEVEL_","");
      //---
      return levelStr;
     }
  };
ENUM_LOG_LEVEL CLogger::m_logLevel=LOG_LEVEL_INFO;
ENUM_LOG_LEVEL CLogger::m_notifyLevel=LOG_LEVEL_FATAL;
ENUM_LOGGING_METHOD CLogger::m_loggingMethod=LOGGING_OUTPUT_METHOD_EXTERN_FILE;
ENUM_NOTIFICATION_METHOD CLogger::m_notificationMethod=NOTIFICATION_METHOD_ALERT;
string CLogger::m_logFileName="";
ENUM_LOG_FILE_LIMIT_TYPE CLogger::m_logFileLimitType=LOG_FILE_LIMIT_TYPE_ONE_DAY;
//+------------------------------------------------------------------+
