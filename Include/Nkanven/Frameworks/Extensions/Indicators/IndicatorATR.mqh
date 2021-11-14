/*
 	IndicatorATR.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CIndicatorATR : public CIndicatorBase {

private:

protected:	// member variables

	int						mPeriods;


public:	// constructors

	CIndicatorATR(int periods)
								:	CIndicatorBase()
								{	Init(periods);	}
	CIndicatorATR(string symbol, ENUM_TIMEFRAMES timeframe,
						int periods)
								:	CIndicatorBase(symbol, timeframe)
								{	Init(periods);	}
	~CIndicatorATR();
	
	virtual int			Init(int periods);

public:

   virtual double GetData(const int buffer_num,const int index);

};

CIndicatorATR::~CIndicatorATR() {

}

int		CIndicatorATR::Init(int periods) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());
	
	mPeriods			=	periods;

#ifdef __MQL5__
	mIndicatorHandle			=	iATR(mSymbol, mTimeframe, mPeriods);
	if (mIndicatorHandle==INVALID_HANDLE)	return(InitError("Failed to create indicator handle", INIT_FAILED));
#endif

	return(INIT_SUCCEEDED);
	
}

double	CIndicatorATR::GetData(const int buffer_num,const int index) {

	double	value	=	0;
	
#ifdef __MQL4__
	value	=	iATR(mSymbol, mTimeframe, mPeriods, index);
#endif

#ifdef __MQL5__
	double	bufferData[];
	ArraySetAsSeries(bufferData, true);
	int cnt	=	CopyBuffer(mIndicatorHandle, buffer_num, index, 1, bufferData);
	if (cnt>0) value	=	bufferData[0];
#endif

	return(value);
	
}


