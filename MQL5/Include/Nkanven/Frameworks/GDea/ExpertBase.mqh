/*
	ExpertBase.mqh

	Copyright 2013-2020, Orchard Forex
	https://www.orchardforex.com

*/


#include	"CommonBase.mqh"
#include "SignalBase.mqh"
#include "TPSLBase.mqh"
#include	"Trade/Trade.mqh"

class CExpertBase : public CCommonBase {

protected:

	int				mMagicNumber;
	string			mTradeComment;
	
	double			mVolume;
	
	datetime			mLastBarTime;
	datetime			mBarTime;

	////Changed
	//	Arrays to hold the signal objects	
	CSignalBase		*mEntrySignals[];
	CSignalBase		*mExitSignals[];
	////CSignalBase		*mEntrySignal;
	////CSignalBase		*mExitSignal;

	double			mTakeProfitValue;
	double			mStopLossValue;
	CTPSLBase		*mTakeProfitObj;
	CTPSLBase		*mStopLossObj;
	
	CTradeCustom	Trade;

private:

protected:

	virtual bool	LoopMain(bool newBar, bool firstTime);
	
protected:

	int				Init(int magicNumber, string tradeComment);

public:

	//
	//	Constructors
	//
	CExpertBase()							: CCommonBase()
												{	Init(0, "");	}
	CExpertBase(string symbol, int timeframe, int magicNumber, string tradeComment)
												:	CCommonBase(symbol, timeframe)
												{	Init(magicNumber, tradeComment);	}
	CExpertBase(string symbol, ENUM_TIMEFRAMES timeframe, int magicNumber, string tradeComment)
												:	CCommonBase(symbol, timeframe)
												{	Init(magicNumber, tradeComment);	}
	CExpertBase(int magicNumber, string tradeComment)
												:	CCommonBase()
												{	Init(magicNumber, tradeComment);	}

	//
	//	Destructors
	//
	~CExpertBase();

public:	//	Default properties

	//
	//	Assign the default values to the expert
	//
	virtual void	SetVolume(double volume)		{	mVolume			=	volume;	}

	virtual void	SetTakeProfitValue(int takeProfitPoints)
																{	mTakeProfitValue	=	PointsToDouble(takeProfitPoints);	}
	virtual void	SetTakeProfitObj(CTPSLBase *takeProfitObj)
																{	mTakeProfitObj	=	takeProfitObj;	}

	virtual void	SetStopLossValue(int stopLossPoints)
																{	mStopLossValue	=	PointsToDouble(stopLossPoints);	}
	virtual void	SetStopLossObj(CTPSLBase *stopLossObj)
																{	mStopLossObj	=	stopLossObj;	}
	
	virtual void	SetTradeComment(string comment)	{	mTradeComment	=	comment;	}
	virtual void	SetMagic(int magicNumber)			{	mMagicNumber	=	magicNumber;
																		Trade.SetExpertMagicNumber(magicNumber);	}

public:	//	Setup

	////Changed
	virtual void	AddEntrySignal(CSignalBase *signal)	{	AddSignal(signal, mEntrySignals);	}
	virtual void	AddExitSignal(CSignalBase *signal)	{	AddSignal(signal, mExitSignals);	}
	virtual void	AddSignal(CSignalBase *signal, CSignalBase* &signals[]);
	////virtual void	AddEntrySignal(CSignalBase *signal)	{	mEntrySignal=signal;	}
	////virtual void	AddExitSignal(CSignalBase *signal)	{	mExitSignal=signal;	}
	
public:	//	Event handlers

	virtual int		OnInit();
	virtual void	OnTick();
	virtual void	OnTimer()			{	return;	}
	virtual double	OnTester()			{	return(0.0);	}
	virtual void	OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {};

#ifdef __MQL5__
	virtual void	OnTrade()			{	return;	}
	virtual void	OnTradeTransaction(const MqlTradeTransaction& trans,
                        					const MqlTradeRequest& request,
                        					const MqlTradeResult& result)
                        				{	return;	}
	virtual int		OnTesterInit()		{	return(INIT_SUCCEEDED);	}
	virtual void	OnTesterPass()		{	return;	}
	virtual void	OnTesterDeinit()	{	return;	}
	virtual void	OnBookEvent()		{	return;	}
#endif

public:	// Functions

	virtual void	GetMarketPrices(ENUM_ORDER_TYPE orderType, MqlTradeRequest &request);
	////New
	virtual ENUM_OFX_SIGNAL_DIRECTION	GetCurrentSignal(CSignalBase* &signals[],
																	ENUM_OFX_SIGNAL_TYPE signalType);
	
};

CExpertBase::~CExpertBase() {

}

int   CExpertBase::OnInit() {

   int   i  =  0;
   for (i=ArraySize(mEntrySignals)-1; i>=0; i--) {
      if (mEntrySignals[i].InitResult()!=INIT_SUCCEEDED) return(mEntrySignals[i].InitResult());
   }
   for (i=ArraySize(mExitSignals)-1; i>=0; i--) {
      if (mExitSignals[i].InitResult()!=INIT_SUCCEEDED) return(mExitSignals[i].InitResult());
   }
   if (mTakeProfitObj!=NULL) {
      if (mTakeProfitObj.InitResult()!=INIT_SUCCEEDED) return(mTakeProfitObj.InitResult());
   }
   if (mStopLossObj!=NULL) {
      if (mStopLossObj.InitResult()!=INIT_SUCCEEDED) return(mStopLossObj.InitResult());
   }

   return(INIT_SUCCEEDED);

}

int	CExpertBase::Init(int magicNumber, string tradeComment) {

	if (mInitResult!=INIT_SUCCEEDED) return(mInitResult);
	
	mTradeComment		=	tradeComment;
	SetMagic(magicNumber);

	mTakeProfitValue	=	0.0;
	mStopLossValue		=	0.0;
		
	mLastBarTime		=	0;
	
	////New
	ArrayResize(mEntrySignals, 0);	//	Just make sure these are initialised
	ArrayResize(mExitSignals, 0);
	
	return(INIT_SUCCEEDED);
	
}

void	CExpertBase::OnTick(void) {

	if (!TradeAllowed()) return;
	
	mBarTime	=	iTime(mSymbol, mTimeframe, 0);

	bool	firstTime	=	(mLastBarTime==0);
	bool	newBar		=	(mBarTime!=mLastBarTime);
	
	if (LoopMain(newBar, firstTime)) {
		mLastBarTime	=	mBarTime;
	}

	return;
	
}

bool		CExpertBase::LoopMain(bool newBar,bool firstTime) {

	//
	//	To start I will only trade on a new bar
	//		and not on the first bar after start
	//
	if (!newBar)	return(true);
	if (firstTime)	return(true);
	
	//
	//	Update the signals
	//
	////Changed
	ENUM_OFX_SIGNAL_DIRECTION	entrySignal	=	GetCurrentSignal(mEntrySignals, OFX_ENTRY_SIGNAL);
	ENUM_OFX_SIGNAL_DIRECTION	exitSignal	=	GetCurrentSignal(mExitSignals, OFX_EXIT_SIGNAL);
	////if (mEntrySignal!=NULL)	mEntrySignal.UpdateSignal();
	////if (mEntrySignal!=mExitSignal) {
	////	if (mExitSignal!=NULL)	mExitSignal.UpdateSignal();
	////}

	//
	//	Should any trades be closed
	//
	////Changed
	if (exitSignal==OFX_SIGNAL_BOTH) {
		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
	} else
	if (exitSignal==OFX_SIGNAL_BUY) {
		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
	} else
	if (exitSignal==OFX_SIGNAL_SELL) {
		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
	}
	////if (mExitSignal!=NULL) {
	////	if (mExitSignal.ExitSignal()==OFX_SIGNAL_BOTH) {
	////		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
	////		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
	////	} else
	////	if (mExitSignal.ExitSignal()==OFX_SIGNAL_BUY) {
	////		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
	////	} else
	////	if (mExitSignal.ExitSignal()==OFX_SIGNAL_SELL) {
	////		Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
	////	}
	////}
	
	//
	//	Should a trade be opened
	//
	MqlTradeRequest	request = {};	//	Just initialising
	////Changed
	if (entrySignal==OFX_SIGNAL_BOTH) {

		GetMarketPrices(ORDER_TYPE_BUY, request);
		Trade.Buy(mVolume, mSymbol, request.price, request.sl, request.tp);

		GetMarketPrices(ORDER_TYPE_SELL, request);
		Trade.Sell(mVolume, mSymbol, request.price, request.sl, request.tp);

	} else
	if (entrySignal==OFX_SIGNAL_BUY) {

		GetMarketPrices(ORDER_TYPE_BUY, request);
		Trade.Buy(mVolume, mSymbol, request.price, request.sl, request.tp);

	} else
	if (entrySignal==OFX_SIGNAL_SELL) {

		GetMarketPrices(ORDER_TYPE_SELL, request);
		Trade.Sell(mVolume, mSymbol, request.price, request.sl, request.tp);

	}
////	if (mEntrySignal!=NULL) {
////		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_BOTH) {
////
////			GetMarketPrices(ORDER_TYPE_BUY, request);
////			Trade.Buy(mVolume, mSymbol, request.price, request.sl, request.tp);
////
////			GetMarketPrices(ORDER_TYPE_SELL, request);
////			Trade.Sell(mVolume, mSymbol, request.price, request.sl, request.tp);
////
////		} else
////		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_BUY) {
////
////			GetMarketPrices(ORDER_TYPE_BUY, request);
////			Trade.Buy(mVolume, mSymbol, request.price, request.sl, request.tp);
////
////		} else
////		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_SELL) {
////
////			GetMarketPrices(ORDER_TYPE_SELL, request);
////			Trade.Sell(mVolume, mSymbol, request.price, request.sl, request.tp);
////
////		}
////	}
	
	return(true);
	
}

void	CExpertBase::GetMarketPrices(ENUM_ORDER_TYPE orderType, MqlTradeRequest &request) {

	double	sl	=	(mStopLossObj==NULL) ? mStopLossValue : mStopLossObj.GetStopLoss();
	double	tp	=	(mTakeProfitObj==NULL) ? mTakeProfitValue : mTakeProfitObj.GetTakeProfit();
	
	if (orderType==ORDER_TYPE_BUY) {
		if (request.price==0.0) request.price	=	SymbolInfoDouble(mSymbol, SYMBOL_ASK);
		request.tp	=	(tp==0.0) ? 0.0 : NormalizeDouble(request.price+tp, mDigits);
		request.sl	=	(sl==0.0) ? 0.0 : NormalizeDouble(request.price-sl, mDigits);
	}

	if (orderType==ORDER_TYPE_SELL) {
		if (request.price==0.0) request.price	=	SymbolInfoDouble(mSymbol, SYMBOL_BID);
		request.tp	=	(tp==0.0) ? 0.0 : NormalizeDouble(request.price-tp, mDigits);
		request.sl	=	(sl==0.0) ? 0.0 : NormalizeDouble(request.price+sl, mDigits);
	}

	return;

}

////New
void	CExpertBase::AddSignal(CSignalBase *signal, CSignalBase* &signals[]) {

	int		index	=	ArraySize(signals);
	ArrayResize(signals, index+1);
	signals[index]	=	signal;
	
}

////New
ENUM_OFX_SIGNAL_DIRECTION	CExpertBase::GetCurrentSignal(CSignalBase* &signals[],
																		ENUM_OFX_SIGNAL_TYPE signalType) {

	ENUM_OFX_SIGNAL_DIRECTION	result	=	OFX_SIGNAL_NONE;
	ENUM_OFX_SIGNAL_DIRECTION	r2			=	OFX_SIGNAL_NONE;	//	Just working value
	int	index	=	ArraySize(signals);
	
	if (index<=0) {

		return(result);
		
	} else {
		
		signals[0].UpdateSignal();
		result	=	signals[0].GetSignal(signalType);

		//	I have chosen to update all signals in case there is some
		//		behavour that needs it. The penalty is some performance
		//	If performance is an issue just add an exit inside the loop
		//		as the commented line		
		for (int i = 1; i<index; i++) {

			//if (result==OFX_SIGNAL_NONE) return(result);
			
			signals[i].UpdateSignal();
			r2			=	signals[i].GetSignal(signalType);
			
			//	The logic here
			//	If the current result is both then just update to the r2
			//		because this allows for any value
			//	If r2 is both then this just leave the current result as is
			//	Last test, meaning result is already none or buy or sell
			//		If r2 is different then we cannot combine them
			//		so the result must be none
			//
			//	or like this
			//
			//	result		r2			gives
			//	Both		+	Any	=	Any
			//	Any		+	Both	=	Any
			//	!Both		+	!Same	=	None
			if (result==OFX_SIGNAL_BOTH)		{	result	=	r2;	}
			else if (r2==OFX_SIGNAL_BOTH)		{	}
			else if (result!=r2)					{	result	=	OFX_SIGNAL_NONE;	}
			
		}
	
	}
		
	return(result);

}	




