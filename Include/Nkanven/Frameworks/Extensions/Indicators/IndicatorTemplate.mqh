/*
 	IndicatorTemplate.mqh
 	Updated as of framework version 2.02
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/

// Next line assumes this file is located in .../Frameworks/Extensions/someFolder 
#include	"../../Framework.mqh"

class CIndicatorTemplate : public CIndicatorBase {

private:

protected:	// member variables

//	Place any required member variables here

public:	// constructors

	//	Add any required constructor arguments
	//	e.g. CIndicatorXYZ(int periods, double multiplier)
	CIndicatorTemplate()
								:	CIndicatorBase()
								{	Init();	}
	// Same constructor with symbol and timeframe added
	CIndicatorTemplate(string symbol, ENUM_TIMEFRAMES timeframe)
								:	CIndicatorBase(symbol, timeframe)
								{	Init();	}
	~CIndicatorTemplate();

	//	Include all arguments to match the constructor
	virtual int			Init();

public:

	//	Add this line to override the same function from the parent class
   virtual double GetData(const int buffer_num,const int index);

};

CIndicatorTemplate::~CIndicatorTemplate() {

	//	Any destructors here
	
}

int		CIndicatorTemplate::Init() {

	//	Checks if init has been set to fail by any parent class already
	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	//	Assign variables and do any other initialisation here	

#ifdef __MQL5__
	//	Just using iMA as an example here, replace as necessary
//	mIndicatorHandle			=	iMA(mSymbol, mTimeframe, mPeriods, mShift, mMethod, mAppliedPrice);
//	if (mIndicatorHandle==INVALID_HANDLE) return(InitError("Failed to create indicator handle", INIT_FAILED));
#endif

	return(INIT_SUCCEEDED);
	
}

double	CIndicatorTemplate::GetData(const int buffer_num,const int index) {

	double	value	=	0;
#ifdef __MQL4__
	//	Next line is just an example using iMA
	//	value	=	iMA(mSymbol, mTimeframe, mPeriods, mShift, mMethod, mAppliedPrice, index);
#endif

#ifdef __MQL5__
	//	For MQL5 once indicator handle is set the code here should be common
	//	Declare a buffer to hold the data being retrieved
	double	bufferData[];
	//	Set as series so the sequence matches the chrt
	ArraySetAsSeries(bufferData, true);
	//	Copy indicator data into the buffer and get the count of elements
	int cnt	=	CopyBuffer(mIndicatorHandle, buffer_num, index, 1, bufferData);
	//	If not enough elements came back then don't use the data
	if (cnt>0) value	=	bufferData[0];
#endif

	return(value);
	
}


