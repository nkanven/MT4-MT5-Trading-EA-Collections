/*
 	SignalTemplate.mqh
 	Updated as of framework version 2.02
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
// Next line assumes this file is located in .../Frameworks/Extensions/someFolder 
#include	"../../Framework.mqh"

class CSignalTemplate : public CSignalBase {

private:

protected:	// member variables

//	Place any required member variables here
	
public:	// constructors

	//	Add any required constructor arguments
	//	e.g. CSignalXYZ(int periods, double multiplier)
	CSignalTemplate()
								:	CSignalBase()
								{	Init();	}
	// Same constructor with symbol and timeframe added
	CSignalTemplate(string symbol, ENUM_TIMEFRAMES timeframe)
								:	CSignalBase(symbol, timeframe)
								{	Init();	}
	~CSignalTemplate()	{	}
	
	//	Include all arguments to match the constructor
	int			Init();

public:

	//	Add this line to override the same function from the parent class
	virtual void								UpdateSignal();

};

int		CSignalTemplate::Init() {

	//	Checks if init has been set to fail by any parent class already
	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	//	Assign variables and do any other initialisation here	
			
	return(INIT_SUCCEEDED);
	
}

void		CSignalTemplate::UpdateSignal() {

	//	Just gather data from the indicators and
	//		decide on a trade direction
	//	This is the trade decision logic

	mExitSignal		=	OFX_SIGNAL_NONE;			//	This strategy has no exit signal
	//	Just set the buy or sell signals now

	return;
	
}

	
