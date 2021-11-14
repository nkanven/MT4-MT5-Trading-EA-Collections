/*
 	SignalBase.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../CommonBase.mqh"
#include	"../Indicators/IndicatorBase.mqh"

struct SIndicatorItem {
	CIndicatorBase	*indicator;
	int				bufferNum;
};

enum ENUM_OFX_SIGNAL_DIRECTION {
	OFX_SIGNAL_NONE	=	0,
	OFX_SIGNAL_BUY		=	1,
	OFX_SIGNAL_SELL	=	2,
	OFX_SIGNAL_BOTH	=	3
};

class CSignalBase : public CCommonBase {

private:

protected:	// member variables

	ENUM_OFX_SIGNAL_DIRECTION	mEntrySignal;
	ENUM_OFX_SIGNAL_DIRECTION	mExitSignal;
	SIndicatorItem					mIndicatorList[];
	
public:	// constructors

	CSignalBase()															:	CCommonBase()
																				{	Init();	}
	CSignalBase(string symbol, ENUM_TIMEFRAMES timeframe)		:	CCommonBase(symbol, timeframe)
																				{	Init();	}
	~CSignalBase()															{	}
	
	int			Init();

public:

	virtual void								UpdateSignal()			{	return;						}
	virtual ENUM_OFX_SIGNAL_DIRECTION	EntrySignal()			{	return(mEntrySignal);	}
	virtual ENUM_OFX_SIGNAL_DIRECTION	ExitSignal()			{	return(mExitSignal);		}
	
	virtual void								AddIndicator(CIndicatorBase *indicator, int bufferNum);
	virtual double								GetIndicatorData(int indicatorNum, int index);

};

int		CSignalBase::Init() {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());
	
	mEntrySignal		=	OFX_SIGNAL_NONE;
	mExitSignal			=	OFX_SIGNAL_NONE;

	return(INIT_SUCCEEDED);
	
}

void		CSignalBase::AddIndicator(CIndicatorBase *indicator, int bufferNum) {

	SIndicatorItem	indicatorItem	=	{NULL, 0};
	indicatorItem.indicator			=	indicator;
	indicatorItem.bufferNum			=	bufferNum;
	int	cnt	=	ArraySize(mIndicatorList);
	ArrayResize(mIndicatorList, cnt+1);
	mIndicatorList[cnt]	=	indicatorItem;
	
	return;

}

double	CSignalBase::GetIndicatorData(int indicatorNum,int index) {

	return(mIndicatorList[indicatorNum].indicator.GetData(mIndicatorList[indicatorNum].bufferNum, index));
	
}


