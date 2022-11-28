//+------------------------------------------------------------------+
//|                                                 Telegram2MT4.mq4 |
//|                       Copyright 2022, Nkondog Anselme Venceslas. |
//|                              https://www.linkedin.com/in/nkondog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Nkondog Anselme Venceslas."
#property link      "https://www.linkedin.com/in/nkondog"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
enum ENUM_RISK_DEFAULT
  {
   RISK_DEFAULT_FIXED = 1,
   RISK_DEFAULT_AUTO  = 2,

  };

input ENUM_RISK_DEFAULT inpRiskDefault = RISK_DEFAULT_FIXED;  //Lot sizing mode

input double inpDefaultLotSize = 0.01;                        //Default lot
input double inpRiskPercent = 0.1;                            //Risk percentage
input double inpMaxLotSize = 10;                              //Max lot
input int inpMaxSlippage = 3;                                 //Max slippage
input int inpMagicNumber = 1987;                              //Magic number
input string inpSymbolPrefix = "";                            //Symbol prefix
input string inpSymbolSuffix = "";                            //Symbol suffix

double vbid,vask,vpoint;
int    vdigits, vspread;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   checkForPermissions();
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
//read file writen by TelegramReader
   readTelegramFile();

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void readTelegramFile()
  {

//--- open the file
   string fileName = "order.bin";
   ResetLastError();
   string table[];

   int file_handle=FileOpen("Telegramreader"+"//"+fileName,FILE_READ|FILE_ANSI, " ");
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for reading",fileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //--- additional variables
      int    str_size;
      string str;
      int i = 0;
      //--- read data from the file
      while(!FileIsEnding(file_handle))
        {
         //--- find out how many symbols are used for writing the time
         str_size=FileReadInteger(file_handle,INT_VALUE);
         //--- read the string
         str=FileReadString(file_handle,str_size);

         //--- print the string
         Print("i" + i + " " + str);
         ArrayResize(table, ArraySize(table) + 1);
         table[i] = str;
         i += 1;
        }
      //--- close the file
      FileClose(file_handle);
      //PrintFormat("Data is read, %s file is closed",fileName);
      FileDelete("Telegramreader"+"//"+fileName);

      sendOrder(table[2], table[0], table[1], NormalizeDouble(table[3], Digits), NormalizeDouble(table[4], Digits), NormalizeDouble(table[5], Digits));
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sendOrder(string type, string direction, string symbol, double entryPrice, double takeProfit, double stopLoss)
  {
   int    ticket = 0;
   symbol = inpSymbolPrefix+symbol+inpSymbolSuffix;
   double lotSize;

   vbid    = MarketInfo(symbol,MODE_BID);
   vask    = MarketInfo(symbol,MODE_ASK);
   vpoint  = MarketInfo(symbol,MODE_POINT);
   vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   vspread = (int)MarketInfo(symbol,MODE_SPREAD);

   Print(type, direction, symbol, entryPrice, takeProfit, stopLoss);
   if(type == "NOW")
     {
      if(direction == "BUY")
        {
         lotSize = LotSizeCalculate(OP_BUY, stopLoss, symbol, vpoint);
         Print("Lot size ", lotSize);

         ticket=OrderSend(symbol,OP_BUY,lotSize,vask,inpMaxSlippage, stopLoss,takeProfit,"Trade from eInvestors",inpMagicNumber,0,Green);
        }

      if(direction == "SELL")
        {

         lotSize = LotSizeCalculate(OP_SELL, stopLoss, symbol, vpoint);
         Print("Lot size ", lotSize);

         ticket=OrderSend(symbol,OP_SELL,lotSize,vbid,inpMaxSlippage, stopLoss,takeProfit,"Trade from eInvestors",inpMagicNumber,0,Green);
        }

      if(ticket>0)
        {
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
            Print("BUY order opened : ",OrderOpenPrice());
        }
      else
         Print("Error opening BUY order : ",GetLastError());
     }


  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|          Compute lot size function                               |
//+------------------------------------------------------------------+
double LotSizeCalculate(int ordertype, double stoploss, string symbol, double vpoint)
  {

   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double riskBaseAmount;
   double lotSize = 0;
   double SL = 0;

   if(stoploss > 0)
     {
      if(ordertype == OP_BUY)
        {
         SL = (vask-stoploss)/vpoint;
        }
      else
         if(ordertype == OP_SELL)
           {
            SL = (stoploss-vbid)/vpoint;
           }
     }
//Print("SL ", SL, " risk base ", AccountInfoDouble(ACCOUNT_BALANCE), "tick value ", tickValue);
   Print("if statement ", SL != 0 && inpRiskDefault == RISK_DEFAULT_AUTO);
   if(SL != 0 && inpRiskDefault == RISK_DEFAULT_AUTO)
     {
      riskBaseAmount = AccountInfoDouble(ACCOUNT_BALANCE);
      lotSize = ((riskBaseAmount*inpRiskPercent/100)/(SL*tickValue));
     }
   else
     {
      lotSize = inpDefaultLotSize;
     }

   lotSize = MathFloor(lotSize/SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP))*SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   if(lotSize > inpMaxLotSize)
     {
      lotSize = inpMaxLotSize;
     }

   if(lotSize > SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX))
     {
      lotSize = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
     }

   if(lotSize < SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN))
     {
      lotSize = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
     }

   return lotSize;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkForPermissions()
  {

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      Alert("Check if automated trading is allowed in the terminal settings!");

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      Alert("Check if automated trading is allowed in the terminal settings!");
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
     }

   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");

   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
  }
//+------------------------------------------------------------------+
