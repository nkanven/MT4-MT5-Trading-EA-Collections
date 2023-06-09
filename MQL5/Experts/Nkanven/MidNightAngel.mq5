//+------------------------------------------------------------------+
//|                                                MidNightAngel.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Nkanven\MidNightAngel\Parameters.mqh>   // EA paramters
#include <Nkanven\MidNightAngel\LotSizeCal.mqh>   // Lot size calculator

ulong    ticket=0;
double   profit;
datetime time;
string   symbol;
long     type;
long     entry;

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

   SymbolInfoTick(_Symbol,last_tick);
   /*storeEquity();
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
     }*/
   CheckSpread();

   if(dt.hour == 0)
     {
      Print("It's trading time. History sum ", checkHistory());
      for(int i=0; i<ArraySize(gStandardRisk); i++)
        {
         if(checkHistory() == gStandardRisk[i])
           {
            gBuyPositioning = STANDARD_BUY;
            break;
           }
        }

      for(int i=0; i<ArraySize(gOneSL); i++)
        {
         if(checkHistory() == gOneSL[i])
           {
            gBuyPositioning = TWO_SL_BUY;
            break;
           }
        }
      if(gTwoSL == checkHistory())
        {
         gBuyPositioning = THREE_SL_BUY;
        }
      if(checkHistory()==0)
        {
         gBuyPositioning = STANDARD_BUY;
        }
      Print("Verify buy ", PositionsTotal()==0 && HasTodayClosingPosition());
      //if(PositionsTotal()==0 && !HasTodayClosingPosition())
      if(PositionsTotal()==0 && !HasTodayClosingPosition() && IsSpreadOK)
        {
         switch(gBuyPositioning)
           {
            case  STANDARD_BUY:
               Print("Buy standard entry");
               ExecuteEntry(InpDefaultSize);
               break;
            case TWO_SL_BUY:
               Print("Buy One SL entry");
               ExecuteEntry(InpOneSlSize);
               break;
            case THREE_SL_BUY:
               Print("Buy Two SL entry");
               ExecuteEntry(InpTwoSlSize);
               break;
            default:
               break;
           }
        }
     }
   Comment("Hour ", dt.hour, " Hour is true", " Balance is actually = ", AccountInfoInteger(ACCOUNT_LOGIN), " File ", FileIsExist(filename));

  }
//+------------------------------------------------------------------+

//Check and return if the spread is not too high
void CheckSpread()
  {
//Get the current spread in points, the (int) transforms the double coming from MarketInfo into an integer to avoid a warning when compiling
   long SpreadCurr=(int)Spread;
   Print("Spread ", Spread);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasTodayClosingPosition()
  {
   datetime timeStart = TimeCurrent() - PeriodSeconds(PERIOD_D1);
   time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
   int totalClosed = 0;

   printf(TimeToString(timeStart));
   HistorySelect(timeStart,TimeCurrent());
   uint     total=HistoryDealsTotal();

   for(uint i=0; i<total; i++)
     {
      //--- essaye de récuperer le ticket des transactions
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         if(TimeToString(time, TIME_DATE) == TimeToString(TimeCurrent(), TIME_DATE))
           {
            totalClosed += 1;
           }
         Print("TIMES ", TimeToString(time, TIME_DATE)," ", TimeToString(TimeCurrent(), TIME_DATE));
        }
     }

   Print("Total closed today ", totalClosed);
   if(totalClosed > 0)
     {
      return true;
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int checkHistory()
  {

   uint     total=HistoryDealsTotal();
   int outCount=0;
   int j=1;

   for(uint i=total; i>0; i--)
     {
      //--- essaye de récuperer le ticket des transactions
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- récupère les propriétés des transactions
         time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         type  =HistoryDealGetInteger(ticket,DEAL_TYPE);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);

         if(entry == DEAL_ENTRY_OUT)
           {

            if(j==1)
              {
               if(profit > 0)
                 {
                  outCount+= 1;
                 }
               else
                 {
                  outCount-= 1;
                 }
              }

            if(j==2)
              {
               if(profit > 0)
                 {
                  outCount+= 1;
                 }
               else
                 {
                  outCount-= 2;
                 }
              }

            if(j==3)
              {
               if(profit > 0)
                 {
                  outCount+= 1;
                 }
               else
                 {
                  outCount-= 3;
                 }
              }
            j+=1;
            Print("date ", TimeToString(time), " type ", entry, " profit ", profit);
           }
        }
     }
   return outCount;
  }
//+------------------------------------------------------------------+


//Execute entry if there is an entry signal
void ExecuteEntry(double LotMultiplier)
  {
   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;

   Print("In buy execution");
   Operation=ORDER_TYPE_BUY; //Set the operation to BUY
   OpenPrice=last_tick.ask;    //Set the open price to Ask price
//If the Stop Loss is fixed and the default stop loss is set
   if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0)
     {
      StopLossPrice=OpenPrice-InpDefaultStopLoss*Point();
     }
//If the Stop Loss is automatic
   if(InpStopLossMode==SL_AUTO)
     {
      //Set the Stop Loss to the custom stop loss price
      //StopLossPrice=last_tick.ask-((last_tick.ask-sell_level));
      StopLossPrice=iLow(Symb, PERIOD_CURRENT, 3);
     }
//If the Take Profix price is fixed and defined
   if(InpTakeProfitMode==TP_FIXED && InpDefaultTakeProfit>0)
     {
      TakeProfitPrice=OpenPrice+InpDefaultTakeProfit*Point();
     }
//If the Take Profit is automatic
   if(InpTakeProfitMode==TP_AUTO)
     {
      //Set the Take Profit to the custom take profit price
      TakeProfitPrice=OpenPrice+((OpenPrice-StopLossPrice)*InpTakeProfitPercent);
     }
//Normalize the digits for the float numbers

   OpenPrice=NormalizeDouble(OpenPrice,Digits());
   StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
   TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());

//Submit the order
   SendOrder(Operation,Symbol(),OpenPrice,StopLossPrice,TakeProfitPrice, LotMultiplier);
  }
//+------------------------------------------------------------------+


//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int Command, string Instrument, double OpenPrice, double SLPrice, double TPPrice, double Multiplier)
  {
   MqlTradeRequest request= {};
   MqlTradeResult  result= {};
//Calculate the position size, if the lot size is zero then exit the function
   double SLPoints=0;
   Print("Stop loss ", SLPrice, " Open price ", OpenPrice);
//If the Stop Loss price is set then find the points of distance between open price and stop loss price, and round it
   if(SLPrice>0)
      SLPoints=MathCeil(MathAbs(OpenPrice-SLPrice)/_Point);
//Call the function to calculate the position size

   Print("Stop loss en point ", SLPoints, " Point ", _Point);
   LotSizeCalculate(SLPoints);
//If the position size is zero then exit and don't submit any orderInit

   Print("Stop loss en point ", SLPoints);
   if(LotSize==0)
      return;

   if(gBuyPositioning == TWO_SL_BUY || gBuyPositioning == THREE_SL_BUY)
     {
      SLPrice=SLPrice-InpDefaultTakeProfit*Point();
     }

   request.action       =TRADE_ACTION_DEAL;                     // type de l'opération de trading
   request.symbol       =Instrument;                              // symbole
   request.volume       =LotSize*Multiplier;                                   // volume de 0.1 lot
   request.type         =Command;                        // type de l'ordre
   request.price        =SYMBOL_TRADE_EXECUTION_MARKET; // prix d'ouverture
   request.sl           =NormalizeDouble(SLPrice,Digits());
   request.tp           =NormalizeDouble(TPPrice,Digits());
   request.type_filling =ORDER_FILLING_FOK;
   request.deviation    =InpSlippage;                           // déviation du prix autorisée
//Submit the order

   if(!OrderSend(request,result))
      PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
//--- informations de l'opération
   PrintFormat("retcode=%u  transaction=%I64u  ordre=%I64u",result.retcode,result.deal,result.order);

   if(result.retcode == TRADE_RETCODE_DONE && result.deal != 0)

      return;
  }
//+------------------------------------------------------------------+
