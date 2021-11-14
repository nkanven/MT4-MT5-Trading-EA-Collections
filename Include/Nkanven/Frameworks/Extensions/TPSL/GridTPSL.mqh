 
// Next line assumes this file is located in .../Frameworks/Extensions/someFolder 
#include	"../../Framework.mqh"

class GridTPSL : public CTPSLBase {

private:

	double	GetValue();

protected:	// member variables

//	Place any required member variables here

public:	// constructors

	//	Add any required constructor arguments
	//	e.g. CTPSLXYZ(int periods, double multiplier)
	GridTPSL()			:	CTPSLBase()							{	Init();	}
	// Same constructor with symbol and timeframe added
	GridTPSL(string symbol, ENUM_TIMEFRAMES timeframe)
								:	CTPSLBase(symbol, timeframe)	{	Init();	}
	~GridTPSL()														{	}
	
	int			Init();

public:

	//	Get and Set functions for additional parameters

	//	Override these from the parent class to get required values
	//	GetValue here is just an example
	virtual double	GetTakeProfit()						{	return(GetValue());			}
	virtual double	GetStopLoss()							{	return(GetValue());			}

};

int		GridTPSL::Init() {

	//	Checks if init has been set to fail by any parent class already
	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	//	Assign variables and do any other initialisation here	
	
	return(INIT_SUCCEEDED);
	
}

//	A simple example of a value function
double	GridTPSL::GetValue() {

	//	Pulls data from an assigned indicator number 0 for bar 1 and multiplies by 2
	double	value	=	0;//GetIndicatorData(0, 1)*2;

	return(value);
	
}