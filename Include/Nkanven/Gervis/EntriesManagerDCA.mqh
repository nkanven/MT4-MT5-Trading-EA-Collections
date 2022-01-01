//+------------------------------------------------------------------+
//|                                         EntriesManagementDCA.mqh |
//|                        Copyright 2021, Nkondog Anselme Venceslas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Nkondog Anselme Venceslas"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//Evaluate if there is an entry signal
void EvaluateEntry()
  {
   Print("Min stop loss ", gMinStopLoss);
   if(!gIsSpreadOK)
     {
      Print("At "+SymbolInfoInteger(gSymbol, SYMBOL_SPREAD)+" for "+InpMaxSpread+" Spread is too high to open a position");
      gSignalEntry=SIGNAL_ENTRY_NEUTRAL;
      return;    //If the spread is too high don't give an entry signal
     }
   if(InpUseTradingHours && !gIsOperatingHours)
     {
      gSignalEntry=SIGNAL_ENTRY_NEUTRAL;
      Print("It's not trading time");
      return;      //If you are using trading hours and it's not a trading hour don't give an entry signal
     }
  }


//Execute entry if there is an entry signal
void ExecuteEntry()
  {
//If there is no entry signal no point to continue, exit the function
   if(gSignalEntry==SIGNAL_ENTRY_NEUTRAL)
      return;
   int Operation;
   double OpenPrice=0;
   double StopLossPrice=0;
   double TakeProfitPrice=0;
//If there is a Buy entry signal
   if(gSignalEntry==SIGNAL_ENTRY_BUY)
     {
      Print("In buy execution");
      Operation=ORDER_TYPE_BUY; //Set the operation to BUY
      OpenPrice=last_tick.ask;    //Set the open price to Ask price

      //If the Take Profix price is fixed and defined
      if(InpTakeProfitMode==TP_FIXED && InpDefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice+InpDefaultTakeProfit*Point();
        }

      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(Operation,Symbol(),OpenPrice,TakeProfitPrice);
     }

   if(gSignalEntry==SIGNAL_ENTRY_SELL)
     {
      Print("In sell execution");
      Operation=ORDER_TYPE_SELL; //Set the operation to SELL
      OpenPrice=last_tick.bid;    //Set the open price to Ask price

      //If the Take Profix price is fixed and defined
      if(InpTakeProfitMode==TP_FIXED && InpDefaultTakeProfit>0)
        {
         TakeProfitPrice=OpenPrice-InpDefaultTakeProfit*Point();
        }

      //Normalize the digits for the float numbers
      OpenPrice=NormalizeDouble(OpenPrice,Digits());
      TakeProfitPrice=NormalizeDouble(TakeProfitPrice,Digits());
      //Submit the order
      SendOrder(Operation,Symbol(),OpenPrice,TakeProfitPrice);
     }
  }

//Send Order Function adjusted to handle errors and retry multiple times
void SendOrder(int Command, string Instrument, double OpenPrice, double TPPrice, datetime Expiration=0)
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

      LotSizeCalculate(SLPoints);
      //If the position size is zero then exit and don't submit any orderInit

      Print("Stop loss en point ", SLPoints);
      if(gLotSize==0)
         return;

      request.action       =TRADE_ACTION_DEAL;                     // type de l'opération de trading
      request.symbol       =Instrument;                              // symbole
      request.volume       =gLotSize;                                   // volume de 0.1 lot
      request.type         =Command;                        // type de l'ordre
      request.price        =SYMBOL_TRADE_EXECUTION_MARKET; // prix d'ouverture
      request.tp           =NormalizeDouble(TPPrice,Digits());
      request.type_filling =ORDER_FILLING_FOK;
      request.deviation    =InpSlippage;
      request.expiration   =Expiration;                             // déviation du prix autorisée
      request.magic        =InpMagicNumber;
      //Submit the order

      //Trade.SellStop(mVolume, NormalizeDouble(request.price,mDigits), mSymbol);
      //Trade.BuyStop(mVolume, request.price, mSymbol);

      if(!OrderSend(request,result))
         PrintFormat("OrderSend erreur %d",GetLastError());     // en cas d'erreur d'envoi de la demande, affiche le code d'erreur
      if(GetLastError()==4756)
         break;
      //--- informations de l'opération
      PrintFormat("retcode=%u  transaction=%I64u  ordre=%I64u",result.retcode,result.deal,result.order);

      if(result.retcode == TRADE_RETCODE_DONE && result.order != 0)
         break;
     }
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void entryConditions()
  {
   double priceDiff;
   gSignalEntry = SIGNAL_ENTRY_NEUTRAL;

//Initialize high

//Set last highest price
   if(gLastHighestPrice > 0)
     {
      if(gLastHighestPrice < last_tick.ask)
        {
         gLastHighestPrice = last_tick.ask;
        }
     }
   else
     {
      gLastHighestPrice = iHigh(gSymbol, PERIOD_D1, 0);
     }

//Check last position opened price
   if(gPositionOpenPrice > 0)
     {
      gLastHighestPrice = gPositionOpenPrice;
     }

//Computer margin call
   priceDiff = gLastHighestPrice - last_tick.ask;
   gPriceChange = (priceDiff*100)/gLastHighestPrice;

   if(gPriceChange >= 0.3)
     {
      gLastHighestPrice = last_tick.ask;
      gSignalEntry = SIGNAL_ENTRY_BUY;
     }
   //Print("Highest price ", gLastHighestPrice);
  }
//+------------------------------------------------------------------+
