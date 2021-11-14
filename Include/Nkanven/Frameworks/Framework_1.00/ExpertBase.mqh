/*
	ExpertBase.mqh
	For framework version 1.0

	Copyright 2013-2020, Orchard Forex
	https://www.orchardforex.com

*/


#include	"CommonBase.mqh"
#include "Signals/SignalBase.mqh"
#include	"Trade/Trade.mqh"

class CExpertBase : public CCommonBase {

protected:

	int				mMagicNumber;
	string			mTradeComment;
	
	double			mVolume;
	
	datetime			mLastBarTime;
	datetime			mBarTime;
	
	CSignalBase		*mEntrySignal;
	CSignalBase		*mExitSignal;
	
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
	virtual void	SetVolume(double volume)			{	mVolume			=	volume;	}
	virtual void	SetTradeComment(string comment)	{	mTradeComment	=	comment;	}
	virtual void	SetMagic(int magicNumber)			{	mMagicNumber	=	magicNumber;
																		Trade.SetExpertMagicNumber(magicNumber);	}

public:	//	Setup

	virtual void	AddEntrySignal(CSignalBase *signal)	{	mEntrySignal=signal;	}
	virtual void	AddExitSignal(CSignalBase *signal)	{	mExitSignal=signal;	}
	
public:	//	Event handlers

	virtual int		OnInit()				{	return(InitResult());	}
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
	virtual void	OnTesterInit()		{	return;	}
	virtual void	OnTesterPass()		{	return;	}
	virtual void	OnTesterDeinit()	{	return;	}
	virtual void	OnBookEvent()		{	return;	}
#endif

};

CExpertBase::~CExpertBase() {

}

int	CExpertBase::Init(int magicNumber, string tradeComment) {

	if (mInitResult!=INIT_SUCCEEDED) return(mInitResult);
	
	mTradeComment		=	tradeComment;
	SetMagic(magicNumber);
	
	mLastBarTime	=	0;
	
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
	if (mEntrySignal!=NULL)	mEntrySignal.UpdateSignal();
	if (mEntrySignal!=mExitSignal) {
		if (mExitSignal!=NULL)	mExitSignal.UpdateSignal();
	}
	
	//
	//	Should any trades be closed
	//
	if (mExitSignal!=NULL) {
		if (mExitSignal.ExitSignal()==OFX_SIGNAL_BOTH) {
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
		} else
		if (mExitSignal.ExitSignal()==OFX_SIGNAL_BUY) {
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_BUY);
		} else
		if (mExitSignal.ExitSignal()==OFX_SIGNAL_SELL) {
			Trade.PositionCloseByType(mSymbol, POSITION_TYPE_SELL);
		}
	}
	
	//
	//	Should a trade be opened
	//
	if (mEntrySignal!=NULL) {
		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_BOTH) {
			Trade.Buy(mVolume, mSymbol);
			Trade.Sell(mVolume, mSymbol);
		} else
		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_BUY) {
			Trade.Buy(mVolume, mSymbol);
		} else
		if (mEntrySignal.EntrySignal()==OFX_SIGNAL_SELL) {
			Trade.Sell(mVolume, mSymbol);
		}
	}
	
	return(true);
	
}


	




