/*
 	IndicatorMA.mqh
 	Updated - requires version 2.01 or later
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CIndicatorMA : public CIndicatorBase {

private:

protected:	// member variables

	int						mPeriods;
	int						mShift;
	ENUM_MA_METHOD			mMethod;
	ENUM_APPLIED_PRICE	mAppliedPrice;

public:	// constructors

	CIndicatorMA(int periods, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
								:	CIndicatorBase()
								{	Init(periods, shift, method, appliedPrice);	}
	CIndicatorMA(string symbol, ENUM_TIMEFRAMES timeframe,
						int periods, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
								:	CIndicatorBase(symbol, timeframe)
								{	Init(periods, shift, method, appliedPrice);	}
	~CIndicatorMA();
	
	virtual int			Init(int periods, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice);

public:

   virtual double GetData(const int buffer_num,const int index);

};

CIndicatorMA::~CIndicatorMA() {

}

int		CIndicatorMA::Init(int periods, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());
	
	mPeriods			=	periods;
	mShift			=	shift;
	mMethod			=	method;
	mAppliedPrice	=	appliedPrice;

#ifdef __MQL5__
	mIndicatorHandle			=	iMA(mSymbol, mTimeframe, mPeriods, mShift, mMethod, mAppliedPrice);
	if (mIndicatorHandle==INVALID_HANDLE)	return(InitError("Failed to create indicator handle", INIT_FAILED));
#endif

	return(INIT_SUCCEEDED);
	
}

double	CIndicatorMA::GetData(const int buffer_num,const int index) {

	double	value	=	0;
#ifdef __MQL4__
	value	=	iMA(mSymbol, mTimeframe, mPeriods, mShift, mMethod, mAppliedPrice, index);
#endif

#ifdef __MQL5__
	double	bufferData[];
	ArraySetAsSeries(bufferData, true);
	int cnt	=	CopyBuffer(mIndicatorHandle, buffer_num, index, 1, bufferData);
	if (cnt>0) value	=	bufferData[0];
#endif

	return(value);
	
}


