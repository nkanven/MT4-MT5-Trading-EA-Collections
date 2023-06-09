//+------------------------------------------------------------------+
//|                                            EntriesManagement.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExecuteEntry()
  {
   double OpenPrice=0.0;
   double TakeProfitPrice=0.0;
   OpenPrice=last_tick.ask;    //Set the open price to Ask price

//If the Take Profix price is fixed and defined
   if(InpDefaultTakeProfit>0 && InpWholePositionTP == 0)
     {
      TakeProfitPrice=OpenPrice+(InpDefaultTakeProfit*point);
     }

   double BuyStopOpenPrice=OpenPrice+(InpBuyCallBack * point), BuyLimitOpenPrice=OpenPrice-(InpBuyCallBack * point);


   double BuyStopTP=BuyStopOpenPrice+(InpDefaultTakeProfit*point);
   double BuyLimitTP=BuyLimitOpenPrice+(InpDefaultTakeProfit*point);

//Normalize the digits for the float numbers
   OpenPrice=NormalizeDouble(OpenPrice,Digits());
   BuyStopOpenPrice=NormalizeDouble(BuyStopOpenPrice, Digits());
   BuyLimitOpenPrice=NormalizeDouble(BuyLimitOpenPrice, Digits());
   TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
   BuyStopTP=NormalizeDouble(BuyStopTP,Digits());
   BuyLimitTP=NormalizeDouble(BuyLimitTP,Digits());



//Place market order
   switch(signal)
     {
      case NO_SIGNAL :
         break;
      case BUY_SIGNAL :
         SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY,gSymbol,OpenPrice,TakeProfitPrice);
         SendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_LIMIT,gSymbol,BuyLimitOpenPrice,BuyLimitTP);
         SendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_STOP,gSymbol,BuyStopOpenPrice,BuyStopTP);
         break;
      /*     case BUY_STOP_SIGNAL :
              BuyStopTP=gUpOpenPrice+InpDefaultTakeProfit*point;
              BuyStopTP=NormalizeDouble(BuyStopTP,Digits());
              SendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_STOP,gSymbol,gUpOpenPrice,BuyStopTP);
              break;*/
           case BUY_LIMIT_SIGNAL :
              BuyLimitTP=gDownOpenPrice+(InpDefaultTakeProfit*point);
              BuyLimitTP=NormalizeDouble(BuyLimitTP,Digits());
              SendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_LIMIT,gSymbol,gDownOpenPrice,BuyLimitTP);
              break;
           case PENDING_ORDERS :
              BuyStopTP=gUpOpenPrice+(InpDefaultTakeProfit*point);
              BuyStopTP=NormalizeDouble(BuyStopTP,Digits());
              BuyLimitTP=gDownOpenPrice+(InpDefaultTakeProfit)*point;
              BuyLimitTP=NormalizeDouble(BuyLimitTP,Digits());
              SendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_STOP,gSymbol,gUpOpenPrice,BuyStopTP);
              SendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_STOP,gSymbol,gDownOpenPrice,BuyLimitTP);
              break;
      default:
         break;
     }
  }

//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int action, int Command, string Instrument, double OpenPrice, double TPPrice=0, double SLPrice=0, datetime Expiration=0)
  {
   MqlTradeRequest request= {};
   MqlTradeResult  result= {};

//Retry a number of times in case the submission fails
   for(int i=1; i<=gOrderOpRetry; i++)
     {
      //Set the color for the open arrow for the order
      /*color OpenColor=clrBlueViolet;
      if(Command==OP_BUY)
        {
         OpenColor=clrChartreuse;
        }
      if(Command==OP_SELL)
        {
         OpenColor=clrDarkTurquoise;
        }*/
      //Calculate the position size, if the lot size is zero then exit the function
      double SLPoints=0;
      Print("Stop loss ", SLPrice, " Open price ", OpenPrice);
      //If the Stop Loss price is set then find the points of distance between open price and stop loss price, and round it
      if(SLPrice>0)
         SLPoints=MathCeil(MathAbs(OpenPrice-SLPrice)/point);
      //Call the function to calculate the position size
      //CheckHistory();
      Print("Stop loss en point ", SLPoints, " Point ", point);
      LotSizeCalculate(SLPoints);
      //If the position size is zero then exit and don't submit any orderInit

      Print("Stop loss en point ", SLPoints);
      Print("gLotSize ", gLotSize);
      if(gLotSize==0)
         return;

      request.action       =action;                     // type de l'opération de trading
      request.symbol       =Instrument;                              // symbole
      request.volume       =gLotSize;                                   // volume de 0.1 lot
      request.type         =Command;                        // type de l'ordre
      request.price        =OpenPrice; // prix d'ouverture
      request.sl           =NormalizeDouble(SLPrice,Digits());
      request.tp           =NormalizeDouble(TPPrice,Digits());
      request.deviation    =InpSlippage;
      request.expiration   =Expiration;                             // déviation du prix autorisée
      request.magic        =InpMagicNumber;

      if(!OrderSend(request,result))
        {
         PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
         request.type_filling =SYMBOL_FILLING_FOK;
         if(!OrderSend(request,result))
           {
            PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
           }
        }
      //--- informations de l'opération
      PrintFormat("retcode=%u  transaction=%I64u  ordre=%I64u",result.retcode,result.deal,result.order);

      if(result.retcode == TRADE_RETCODE_DONE && result.order != 0)
         break;
     }
   return;
  }
//+------------------------------------------------------------------+
