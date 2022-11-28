/*
 	SignalCombination.mqh
 	For framework version 1.0
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CSignalCombination : public CSignalBase {

private:

protected:	// member variables

	CSignalBase		*mSignals[];
	
public:	// constructors

	CSignalCombination(string symbol, ENUM_TIMEFRAMES timeframe)
								:	CSignalBase(symbol, timeframe)
								{	Init();	}
	CSignalCombination()
								:	CSignalBase()
								{	Init();	}
	~CSignalCombination()	{	}
	
	int			Init();

public:

	virtual void								AddSignal(CSignalBase *signal);
	virtual void								UpdateSignal();

};

int		CSignalCombination::Init() {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	ArrayResize(mSignals, 0);
	
	return(INIT_SUCCEEDED);
	
}

void		CSignalCombination::UpdateSignal() {

	int	index	=	ArraySize(mSignals);
	
	if (index<=0) {
	
		mEntrySignal	=	OFX_SIGNAL_NONE;
		mExitSignal		=	OFX_SIGNAL_NONE;
		
	} else {
		
		mSignals[0].UpdateSignal();
		mEntrySignal	=	mSignals[0].EntrySignal();
		mExitSignal		=	mSignals[0].ExitSignal();
		
		for (int i = 1; i<index; i++) {
		
			mSignals[i].UpdateSignal();
			if (mSignals[i].EntrySignal()!=mEntrySignal)	mEntrySignal	=	OFX_SIGNAL_NONE;
			if (mSignals[i].ExitSignal()!=mExitSignal)	mExitSignal		=	OFX_SIGNAL_NONE;
			
		}
	
	}
		
	return;
	
}

void		CSignalCombination::AddSignal(CSignalBase *signal) {

	int		index	=	ArraySize(mSignals);
	ArrayResize(mSignals, index+1);
	mSignals[index]	=	signal;
	
}

	
