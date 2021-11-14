/*
 	TPSLTemplate.mqh
 	Updated as of framework version 2.02
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
// Next line assumes this file is located in .../Frameworks/Extensions/someFolder 
#include	"../../Framework.mqh"

class CTPSLTemplate : public CTPSLBase {

private:

	double	GetValue();

protected:	// member variables

//	Place any required member variables here

public:	// constructors

	//	Add any required constructor arguments
	//	e.g. CTPSLXYZ(int periods, double multiplier)
	CTPSLTemplate()			:	CTPSLBase()							{	Init();	}
	// Same constructor with symbol and timeframe added
	CTPSLTemplate(string symbol, ENUM_TIMEFRAMES timeframe)
								:	CTPSLBase(symbol, timeframe)	{	Init();	}
	~CTPSLTemplate()														{	}
	
	int			Init();

public:

	//	Get and Set functions for additional parameters

	//	Override these from the parent class to get required values
	//	GetValue here is just an example
	virtual double	GetTakeProfit()						{	return(GetValue());			}
	virtual double	GetStopLoss()							{	return(GetValue());			}

};

int		CTPSLTemplate::Init() {

	//	Checks if init has been set to fail by any parent class already
	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	//	Assign variables and do any other initialisation here	
	
	return(INIT_SUCCEEDED);
	
}

//	A simple example of a value function
double	CTPSLTemplate::GetValue() {

	//	Pulls data from an assigned indicator number 0 for bar 1 and multiplies by 2
	double	value	=	0;//GetIndicatorData(0, 1)*2;

	return(value);
	
}

	
