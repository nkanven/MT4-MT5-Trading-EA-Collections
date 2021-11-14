/*
 	IndicatorMA.mqh
 	For framework version 1.0
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../IndicatorBase.mqh"

class CIndicatorMA : public CIndicatorBase {

private:

protected:	// member variables

	int						mPeriods;
	int						mShift;
	ENUM_MA_METHOD			mMethod;
	ENUM_APPLIED_PRICE	mAppliedPrice;

	//	Only used for MQL5
	int						mHandle;

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

#ifdef __MQL5__

	if (mHandle!=INVALID_HANDLE) IndicatorRelease(mHandle);
	
#endif

}

int		CIndicatorMA::Init(int periods, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());
	
	mPeriods			=	periods;
	mShift			=	shift;
	mMethod			=	method;
	mAppliedPrice	=	appliedPrice;

#ifdef __MQL5__
	mHandle			=	iMA(mSymbol, mTimeframe, mPeriods, mShift, mMethod, mAppliedPrice);
	if (mHandle==INVALID_HANDLE)	return(InitError("Failed to create indicator handle", INIT_FAILED));
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
	int cnt	=	CopyBuffer(mHandle, buffer_num, index, 1, bufferData);
	if (cnt>0) value	=	bufferData[0];
#endif

	return(value);
	
}


