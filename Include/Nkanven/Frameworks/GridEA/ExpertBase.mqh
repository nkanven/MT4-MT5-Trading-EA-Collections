/*
   ExpertBase.mqh

   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com

*/


#include "CommonBase.mqh"
#include "Trade/Trade.mqh"
#include "../Extensions/AllGridExtensions.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CExpertBase : public CCommonBase
  {

protected:

   int               mMagicNumber;
   string            mTradeComment;

   double            mVolume;

   int               GridNumber;
   int               mGridGap;
   int               mSlippage;
   double            mDefaultLotSize;
   double            mMaxLotSize;
   double            mMinLotSize;
   double            mMaxRiskPerTrade;

   ENUM_TRADING_SESSION    mUseTradingSession;
   ENUM_RISK_DEFAULT_SIZE mRiskDefaultSize;
   ENUM_RISK_BASE    mRiskBase;

   /*enum ENUM_NAV_SIGNAL_TYPE
     {
      NAV_ENTRY_SIGNAL,
      NAV_EXIT_SIGNAL
     };

   ENUM_NAV_SIGNAL_TYPE signalType;

   enum ENUM_NAV_SIGNAL_DIRECTION
     {
      NAV_SIGNAL_NONE            =  0,
      NAV_SIGNAL_BUY             =  1,
      NAV_SIGNAL_SELL            =  2,
      NAV_SIGNAL_BOTH            =  3,
      NAV_SIGNAL_ALL             = 4
     };*/

   //ENUM_NAV_SIGNAL_DIRECTION signalDirection;

   datetime          mLastBarTime;
   datetime          mBarTime;

   bool              mResetGrid;

   ////Changed
   // Arrays to hold the signal objects
   CSignalGrid       *mEntrySignals[];
   CSignalGrid       *mExitSignals[];
   ////CSignalBase      *mEntrySignal;
   ////CSignalBase      *mExitSignal;

   double            mTakeProfitValue;
   double            mStopLossValue;
   GridTPSL          *mTakeProfitObj;
   GridTPSL          *mStopLossObj;

   CTradeCustom      Trade;

private:

protected:

   virtual bool      LoopMain(bool newBar, bool firstTime);

protected:

   int               Init(int magicNumber, string tradeComment);

public:

   //
   // Constructors
   //
                     CExpertBase()                    : CCommonBase()
     {               Init(0, "");   }
                     CExpertBase(string symbol, int timeframe, int magicNumber, string tradeComment)
      :              CCommonBase(symbol, timeframe)
     {               Init(magicNumber, tradeComment); }
                     CExpertBase(string symbol, ENUM_TIMEFRAMES timeframe, int magicNumber, string tradeComment)
      :              CCommonBase(symbol, timeframe)
     {               Init(magicNumber, tradeComment); }
                     CExpertBase(int magicNumber, string tradeComment)
      :              CCommonBase()
     {               Init(magicNumber, tradeComment); }

   //
   // Destructors
   //
                    ~CExpertBase();

public:  // Default properties

   //
   // Assign the default values to the expert
   //
   virtual void      SetVolume(double volume)      {  mVolume        =  volume;  }

   virtual void      SetTakeProfitValue(int takeProfitPoints)
     {  mTakeProfitValue  =  PointsToDouble(takeProfitPoints);   }
   virtual void      SetTakeProfitObj(CTPSLBase *takeProfitObj)
     {  mTakeProfitObj =  takeProfitObj; }

   virtual void      SetStopLossValue(int stopLossPoints)
     {  mStopLossValue =  PointsToDouble(stopLossPoints);  }
   virtual void      SetStopLossObj(CTPSLBase *stopLossObj)
     {  mStopLossObj   =  stopLossObj;   }

   virtual void      SetTradeComment(string comment)  {  mTradeComment  =  comment; }
   virtual void      SetMagic(int magicNumber)
     {
      mMagicNumber   =  magicNumber;
      Trade.SetExpertMagicNumber(magicNumber);
     }

   virtual void      SetGridNumber(int gNumber) {GridNumber = gNumber;}
   virtual void      SetGridGap(int gGap) {mGridGap = gGap;}
   virtual void      SetResetGrid() {mResetGrid = true;}
   virtual void      SetSlippage(int slippage) {mSlippage = slippage;}
   virtual void      SetDefaultLotSize(double defaultLotSize) {mDefaultLotSize = defaultLotSize;}
   virtual void      SetMaxLotSize(double maxLotSize) {mMaxLotSize = maxLotSize;}
   virtual void      SetMinLotSize(double minLotSize) {mMinLotSize = minLotSize;}
   virtual void      SetMaxRiskPerTrade(double maxRiskPerTrade) {mMaxRiskPerTrade = maxRiskPerTrade;}


   virtual void      SetUseTradingSession(ENUM_TRADING_SESSION useTradingSession) {mUseTradingSession = useTradingSession;}
   virtual void      SetRiskDefaultSize(ENUM_RISK_DEFAULT_SIZE riskDefaultSize) { mRiskDefaultSize = riskDefaultSize;}
   virtual void      SetRiskBase(ENUM_RISK_BASE riskBase) {mRiskBase=riskBase;}

public:  // Setup

   ////Changed
   virtual void      AddEntrySignal(CSignalGrid *signal) {  AddSignal(signal, mEntrySignals);   }
   virtual void      AddExitSignal(CSignalGrid *signal)  {  AddSignal(signal, mExitSignals); }
   virtual void      AddSignal(CSignalGrid *signal, CSignalGrid* &signals[]);
   virtual void      LotSize(double SL);
   virtual void      TradeWatcher();
   virtual bool      IsTradingTime();
   virtual bool      CheckTradingSession();

   ////virtual void  AddEntrySignal(CSignalBase *signal) {  mEntrySignal=signal; }
   ////virtual void  AddExitSignal(CSignalBase *signal)  {  mExitSignal=signal;  }

public:  // Event handlers

   virtual int       OnInit();
   virtual void      OnTick();
   virtual void      OnTimer()         {  return;  }
   virtual double    OnTester()        {  return(0.0);   }
   virtual void      OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {};

#ifdef __MQL5__
   virtual void      OnTrade()         {  return;  }
   virtual void      OnTradeTransaction(const MqlTradeTransaction& trans,
                                        const MqlTradeRequest& request,
                                        const MqlTradeResult& result)
     {  return;  }
   virtual int       OnTesterInit()    {  return(INIT_SUCCEEDED); }
   virtual void      OnTesterPass()    {  return;  }
   virtual void      OnTesterDeinit()  {  return;  }
   virtual void      OnBookEvent()     {  return;  }
#endif

public:  // Functions

   virtual void      GetMarketPrices(ENUM_ORDER_TYPE orderType, MqlTradeRequest &request);
   ////New
   virtual ENUM_OFX_SIGNAL_DIRECTION   GetCurrentSignal(CSignalGrid* &signals[],
         ENUM_OFX_SIGNAL_TYPE signalType);

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CExpertBase::~CExpertBase()
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   CExpertBase::OnInit()
  {

   int   i  =  0;
   for(i=ArraySize(mEntrySignals)-1; i>=0; i--)
     {
      if(mEntrySignals[i].InitResult()!=INIT_SUCCEEDED)
         return(mEntrySignals[i].InitResult());
     }
   for(i=ArraySize(mExitSignals)-1; i>=0; i--)
     {
      if(mExitSignals[i].InitResult()!=INIT_SUCCEEDED)
         return(mExitSignals[i].InitResult());
     }
   if(mTakeProfitObj!=NULL)
     {
      if(mTakeProfitObj.InitResult()!=INIT_SUCCEEDED)
         return(mTakeProfitObj.InitResult());
     }
   if(mStopLossObj!=NULL)
     {
      if(mStopLossObj.InitResult()!=INIT_SUCCEEDED)
         return(mStopLossObj.InitResult());
     }

   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   CExpertBase::Init(int magicNumber, string tradeComment)
  {

   if(mInitResult!=INIT_SUCCEEDED)
      return(mInitResult);

   mTradeComment     =  tradeComment;
   SetMagic(magicNumber);

   mTakeProfitValue  =  0.0;
   mStopLossValue    =  0.0;

   mLastBarTime      =  0;

////New
   ArrayResize(mEntrySignals, 0);   // Just make sure these are initialised
   ArrayResize(mExitSignals, 0);

   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CExpertBase::OnTick(void)
  {

   if(!TradeAllowed())
      return;

   mBarTime =  iTime(mSymbol, mTimeframe, 0);

   bool  firstTime   = (mLastBarTime==0);
   bool  newBar      = (mBarTime!=mLastBarTime);

//TradeWatcher();
   if(LoopMain(newBar, firstTime))
     {
      mLastBarTime   =  mBarTime;
     }

   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool     CExpertBase::LoopMain(bool newBar,bool firstTime)
  {

//
// To start I will only trade on a new bar
//    and not on the first bar after start
//
   /*if(!newBar)
      return(true);
   if(firstTime)
      return(true);*/

//
// Update the signals
//
////Changed
   ENUM_OFX_SIGNAL_DIRECTION  entrySignal =  GetCurrentSignal(mEntrySignals, OFX_ENTRY_SIGNAL);
   ENUM_OFX_SIGNAL_DIRECTION  exitSignal  =  GetCurrentSignal(mExitSignals, OFX_EXIT_SIGNAL);


   Print("entrySignal  ", entrySignal);

//
// Should a trade be opened
//
   MqlTradeRequest   request = {};  // Just initialising

   double sellPrice, SLPoints=0;
   int GripPips = mGridGap;
   double TakeProfitPoint = GripPips*_Point;
   LotSize(GripPips);

   if(entrySignal==OFX_SIGNAL_BOTH)
     {
      double AskPrice = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      double BidPrice = SymbolInfoDouble(Symbol(),SYMBOL_BID);

      GetMarketPrices(ORDER_TYPE_BUY, request);
      
      if(Trade.Buy(mVolume, mSymbol))
        {
         GetMarketPrices(ORDER_TYPE_SELL_STOP, request);
         sellPrice = BidPrice - TakeProfitPoint;
         request.price = NormalizeDouble(sellPrice, mDigits);

         Trade.SellStop(mVolume, request.price, mSymbol, request.sl, request.tp);
        }
      else
        {
         Print("Get last error code ", GetLastError());
        }


     }
   else
      if(entrySignal==OFX_SIGNAL_BUY)
        {
         //If there's a pending order, get the last order's price else get the position price
         Print("Trying to open a buy");

         GetMarketPrices(ORDER_TYPE_BUY_STOP, request);
         Trade.BuyStop(mVolume, request.price, mSymbol, request.sl, request.tp);

        }
      else
         if(entrySignal==OFX_SIGNAL_SELL)
           {
            Print("Trying to open a sell");

            GetMarketPrices(ORDER_TYPE_SELL_STOP, request);
            Trade.SellStop(mVolume, request.price, mSymbol, request.sl, request.tp);

           }
   if(exitSignal==OFX_SIGNAL_ALL)
     {
      Trade.OrderCloseAll();
      Trade.PositionCloseAll();
     }

   return(true);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CExpertBase::GetMarketPrices(ENUM_ORDER_TYPE orderType, MqlTradeRequest &request)
  {

   double   sl = (mStopLossObj==NULL) ? mStopLossValue : mStopLossObj.GetStopLoss();
   double   tp = (mTakeProfitObj==NULL) ? mTakeProfitValue : mTakeProfitObj.GetTakeProfit();
   double   sellPrice, buyPrice;

   Trade.SetExpertMagicNumber(mMagicNumber);
   if(orderType==ORDER_TYPE_BUY)
     {
      request.price  =  SymbolInfoDouble(mSymbol, SYMBOL_ASK);
      request.tp  = (tp==0.0) ? 0.0 : NormalizeDouble(request.price+tp, mDigits);
      request.sl  = (sl==0.0) ? 0.0 : NormalizeDouble(request.price-sl, mDigits);
     }

   if(orderType==ORDER_TYPE_SELL)
     {
      request.price  =  SymbolInfoDouble(mSymbol, SYMBOL_BID);
      request.tp  = (tp==0.0) ? 0.0 : NormalizeDouble(request.price-tp, mDigits);
      request.sl  = (sl==0.0) ? 0.0 : NormalizeDouble(request.price+sl, mDigits);
     }

   if(orderType==ORDER_TYPE_SELL_STOP)
     {
      sellPrice = mEntrySignals[0].getLastSellOrderPrice()?mEntrySignals[0].getLastSellOrderPrice():mEntrySignals[0].getOpenedSellPositionPrice();
      sellPrice = (sellPrice==0.0)?SymbolInfoDouble(mSymbol, SYMBOL_BID):sellPrice;

      request.price = sellPrice-(mGridGap*_Point);

      request.tp  = (tp==0.0) ? 0.0 : NormalizeDouble(request.price-tp, mDigits);
      request.sl  = (sl==0.0) ? 0.0 : NormalizeDouble(request.price+sl, mDigits);
     }

   if(orderType==ORDER_TYPE_BUY_STOP)
     {
      buyPrice = mEntrySignals[0].getLastBuyOrderPrice()?mEntrySignals[0].getLastBuyOrderPrice():mEntrySignals[0].getOpenedBuyPositionPrice();
      buyPrice = (buyPrice==0.0)?SymbolInfoDouble(mSymbol, SYMBOL_ASK):buyPrice;
      request.price = buyPrice+(mGridGap*_Point);
      request.tp  = (tp==0.0) ? 0.0 : NormalizeDouble(request.price-tp, mDigits);
      request.sl  = (sl==0.0) ? 0.0 : NormalizeDouble(request.price+sl, mDigits);
     }

   return;

  }

////New
void  CExpertBase::AddSignal(CSignalGrid *signal, CSignalGrid* &signals[])
  {

   int      index =  ArraySize(signals);
   ArrayResize(signals, index+1);
   signals[index] =  signal;

  }

////New
ENUM_OFX_SIGNAL_DIRECTION  CExpertBase::GetCurrentSignal(CSignalGrid* &signals[],
      ENUM_OFX_SIGNAL_TYPE signalType)
  {

   ENUM_OFX_SIGNAL_DIRECTION  result   =  OFX_SIGNAL_NONE;
   ENUM_OFX_SIGNAL_DIRECTION  r2       =  OFX_SIGNAL_NONE;  // Just working value
   int   index =  ArraySize(signals);

   if(index<=0)
     {

      return(result);

     }
   else
     {

      signals[0].UpdateSignal();
      result   =  signals[0].GetSignal(signalType);

      // I have chosen to update all signals in case there is some
      //    behavour that needs it. The penalty is some performance
      // If performance is an issue just add an exit inside the loop
      //    as the commented line
      for(int i = 1; i<index; i++)
        {

         if(result==OFX_SIGNAL_NONE)
            return(result);

         signals[i].UpdateSignal();
         r2       =  signals[i].GetSignal(signalType);

         // The logic here
         // If the current result is both then just update to the r2
         //    because this allows for any value
         // If r2 is both then this just leave the current result as is
         // Last test, meaning result is already none or buy or sell
         //    If r2 is different then we cannot combine them
         //    so the result must be none
         //
         // or like this
         //
         // result      r2       gives
         // Both     +  Any   =  Any
         // Any      +  Both  =  Any
         // !Both    +  !Same =  None
         if(result==OFX_SIGNAL_BOTH)
           {
            result   =  r2;
           }
         else
            if(r2==OFX_SIGNAL_BOTH)    {  }
            else
               if(result!=r2)
                 {
                  result   =  OFX_SIGNAL_NONE;
                 }

        }

     }

   return(result);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertBase::CheckTradingSession()
  {
   string candles_times;
   int    time_to_string;
   ushort a;
   string result[];
//--- Get the separator code
   a = StringGetCharacter(":",0);
   candles_times = TimeToString(iTime(Symbol(),_Period,0), TIME_MINUTES);
   time_to_string = StringSplit(candles_times, a, result);

//Implement this later
   /*
   if(InpUseTradingSession)
     {
      if(InpTradingSession == LONDON_SESSION && londonSession[0] <= result[0] && londonSession[1] >= result[0])
        {
         londonSession
        }
      return;
     }*/
   return true;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertBase::IsTradingTime(void)
  {
   bool result = false;

   if(mUseTradingSession)
      result = true;

   return result;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertBase::LotSize(double SL=0)
  {

//Lot Size Calculator

//If the position size is dynamic
   if(mRiskDefaultSize==RISK_DEFAULT_AUTO)
     {
      //If the stop loss is not zero then calculate the lot size
      Print("Stop loss ", SL);
      if(SL!=0)
        {
         double RiskBaseAmount=0;
         //TickValue is the value of the individual price increment for 1 lot of the instrument, expressed in the account currenty
         double TickValue=SymbolInfoDouble(mSymbol,SYMBOL_TRADE_TICK_VALUE);
         Print("Tick value ", TickValue);
         //Define the base for the risk calculation depending on the parameter chosen
         if(mRiskBase==RISK_BASE_BALANCE)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_BALANCE);
         if(mRiskBase==RISK_BASE_EQUITY)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_EQUITY);
         if(mRiskBase==RISK_BASE_FREEMARGIN)
            RiskBaseAmount=AccountInfoDouble(ACCOUNT_FREEMARGIN);

         //Calculate the Position Size
         mVolume=((RiskBaseAmount*mMaxRiskPerTrade/100)/(SL*TickValue));
         Print("Volume ", mVolume);
        }
      //If the stop loss is zero then the lot size is the default one
      if(SL==0)
        {
         mVolume=mDefaultLotSize;
        }
     }
//Normalize the Lot Size to satisfy the allowed lot increment and minimum and maximum position size
   mVolume=MathFloor(mVolume/SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_STEP))*SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_STEP);

//Limit the lot size in case it is greater than the maximum allowed by the user
   if(mVolume>mMaxLotSize)
      mVolume=mMaxLotSize;
//Limit the lot size in case it is greater than the maximum allowed by the broker
   if(mVolume>SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_MAX))
      mVolume=SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_MAX);
   Print("Lot ", mVolume, " Max lot ", SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_MAX));
//If the lot size is too small then set it to 0 and don't trade
   if(mVolume<mMinLotSize || mVolume < SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_MIN))
     {
      mVolume=0;
      Print("Lot size too small : ", mVolume);
     }


  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
void CExpertBase::TradeWatcher(void)
  {


// Check the account balance equity for profit
   int pCountBuy = 0, pCountSell = 0, oCountBuy = 0, oCountSell = 0, totalBuy = 0, totalSell = 0, realTotalBuy = 0, realTotalSell = 0;
   int realOCountBuy, realOCountSell;
   ulong ticket;
   entrySignal = OFX_SIGNAL_NONE;

//If there're many positions and account balance is negative

   Print("There is ", PositionsTotal(), " opened positions");
   if(PositionsTotal() > 0)
     {
      //Count the opened positions by type
      int   cntP      =  PositionsTotal();
      for(int i = cntP-1; i>=0; i--)
        {
         ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
           {
            if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY
               && PositionGetInteger(POSITION_MAGIC)==mMagicNumber)
              {
               openedBuyPositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               pCountBuy += 1;
              }

            Print("POSITION_SYMBOL ", PositionGetString(POSITION_SYMBOL), " = ", mSymbol, " POSITION_TYPE ",PositionGetInteger(POSITION_TYPE), " = ", POSITION_TYPE_SELL, " Magic ", PositionGetInteger(POSITION_MAGIC), " = ",mMagicNumber);
            if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL
               && PositionGetInteger(POSITION_MAGIC)==mMagicNumber)
              {
               openedSellPositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               pCountSell += 1;
              }
           }
         else
           {
            Print(GetLastError());
           }
        }
     }
//Count the orders by type
/*
   int   cntO      =  OrdersTotal();
   Print("Total pending orders ", cntO);
   for(int i = cntO-1; i>=0; i--)
     {
      ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetString(ORDER_SYMBOL)==mSymbol && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP
            && OrderGetInteger(ORDER_MAGIC)==mMagicNumber)
           {
            oCountBuy += 1;
            lastBuyOrderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
           }

         Print("ORDER_SYMBOL ", OrderGetString(ORDER_SYMBOL), " Real symbol ", mSymbol, " ORDER_TYPE ", OrderGetInteger(ORDER_TYPE), " Real type ", ORDER_TYPE_SELL_STOP, " Magic ", OrderGetInteger(ORDER_MAGIC), " Real magic ", mMagicNumber);
         if(OrderGetString(ORDER_SYMBOL)==mSymbol && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_STOP
            && OrderGetInteger(ORDER_MAGIC)==mMagicNumber)
           {
            oCountSell += 1;
            lastSellOrderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
           }
        }
      else
        {
         Print(GetLastError());
        }
     }
   Print("openedBuyPositionPrice ", openedBuyPositionPrice, " openedSellPositionPrice ", openedSellPositionPrice);

   Print("lastBuyOrderPrice ", lastBuyOrderPrice, " lastSellOrderPrice ", lastSellOrderPrice);

   double floatingProfitPercent = ((AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE))*100)/AccountInfoDouble(ACCOUNT_BALANCE);
// Check if profit is at least the mMaxRiskPerTrade

   Print(" MaxRiskPerTrade ",mMaxRiskPerTrade, " Floating profit percent ", floatingProfitPercent, " Account equity ", AccountInfoDouble(ACCOUNT_EQUITY), " Account balance ", AccountInfoDouble(ACCOUNT_BALANCE));

//The number of buy pending order should be twice the opened sell positions; and vice versa
   realOCountBuy = pCountSell+1;
   realOCountSell = pCountBuy*2;
   totalBuy = pCountBuy+oCountBuy;
   totalSell = pCountSell+oCountSell;
   realTotalBuy = pCountSell+1;
   realTotalSell = pCountBuy+1;

   Print("Sell order (", oCountSell, ") Real (", realOCountSell, ")");
   Print("Buy order (", oCountBuy, ") Real (", realOCountBuy, ")", " Opened sell ", pCountSell);


   Print("oCountSell ", oCountSell, " < ", " realOCountSell ", realOCountSell, " && ", " pCountBuy ", pCountBuy," > 0");

   if(OrdersTotal() == 0 && PositionsTotal() == 0)
     {
      signalDirection = OFX_SIGNAL_BOTH;
     }
   else
     {
      //If there's only one pending order left, close it.
      if(OrdersTotal() >= 1 && PositionsTotal() == 0)
        {
         signalDirection =  OFX_SIGNAL_ALL;
         Print("Exit if no opened position");
        }
      else
        {
         //When there are multiple positions, check is the account is making enough profit
         if(floatingProfitPercent > mMaxRiskPerTrade)
           {
            signalDirection = OFX_SIGNAL_ALL;
            Print("Exit on profit target");
           }
         else
           {
           Print("realTotalSell ", realTotalSell, " <= ", " totalSell ", totalSell ," && ", " pCountBuy ",pCountBuy ," > 0");
            if(realTotalSell > totalSell && pCountBuy > 0)
              {
               signalType = OFX_ENTRY_SIGNAL;
               signalDirection = OFX_SIGNAL_SELL;
               Print("Sell order (", oCountSell, ") is less than it should be (", realOCountSell, ")");
              }
            else
              {
               if(realTotalBuy > totalBuy && pCountSell > 0)
                 {
                  signalType = OFX_ENTRY_SIGNAL;
                  signalDirection = OFX_SIGNAL_BUY;
                  //mEntrySignals[0].SetSignal(OFX_ENTRY_SIGNAL, OFX_SIGNAL_BUY);
                  Print("Buy order (", oCountBuy, ") is less than it should be (", realOCountBuy, ")");
                 }
              }
           }
        }
     }
  }*/
//+------------------------------------------------------------------+
