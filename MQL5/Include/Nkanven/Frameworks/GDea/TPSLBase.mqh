/*
 	TPSLBase.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/

#include "Signalbase.mqh"

class CTPSLBase : public CSignalBase {

private:

public:	// constructors

	CTPSLBase()															:	CSignalBase()							{	Init();	}
	CTPSLBase(string symbol, ENUM_TIMEFRAMES timeframe)	:	CSignalBase(symbol, timeframe)	{	Init();	}
	~CTPSLBase()																										{	}
	
	int			Init();

public:

	virtual double							GetTakeProfit()	{	return(0.0);	}
	virtual double							GetStopLoss()		{	return(0.0);	}

};

int		CTPSLBase::Init() {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());
	
	return(INIT_SUCCEEDED);
	
}



