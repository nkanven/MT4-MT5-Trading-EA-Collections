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

   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;
   bool yu =  false;

//Place market order
   if(yu)
     {

      OpenPrice=last_tick.ask;    //Set the open price to Ask price

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice-(InpDefaultStopLoss*Point());
        }

      //If the Stop Loss is set to automatic
      if(InpStopLossMode==SL_AUTO)
        {
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=0;
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
         TakeProfitPrice=0;
        }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);

     }

   if(yu)
     {

      OpenPrice=last_tick.bid;    //Set the open price to Ask price

      //InpAtrMultiplier

      //If the Stop Loss is fixed and the default stop loss is set
      if(InpStopLossMode==SL_FIXED && InpDefaultStopLoss>0)
        {
         StopLossPrice=OpenPrice+(InpDefaultStopLoss*Point());
        }

      //If the Stop Loss is set to automatic
      if(InpStopLossMode==SL_AUTO)
        {
         //Set the Stop Loss to the custom stop loss price
         StopLossPrice=0;
        }

      //If the Take Profix price is fixed and defined
      if(InpTakeProfitMode==TP_FIXED && InpDefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice-InpDefaultTakeProfit*Point();
        }
      //If the Take Profit is automatic
      if(InpTakeProfitMode==TP_AUTO)
        {
         //Set the Take Profit to the custom take profit price
         TakeProfitPrice=0;
        }
      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      StopLossPrice=NormalizeDouble(StopLossPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_SELL,gSymbol,OpenPrice,StopLossPrice,TakeProfitPrice);
     }
  }

//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int action, int Command, string Instrument, double OpenPrice, double SLPrice, double TPPrice, datetime Expiration=0)
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
         SLPoints=MathCeil(MathAbs(OpenPrice-SLPrice)/_Point);
      //Call the function to calculate the position size
      //CheckHistory();
      Print("Stop loss en point ", SLPoints, " Point ", _Point);
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