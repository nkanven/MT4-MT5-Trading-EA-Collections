/*
 	TPSLSimple.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../../Framework.mqh"

class CTPSLSimple : public CTPSLBase {

private:

	double	GetValue();

protected:	// member variables

	double	mMultiplier;
	int		mIndex;

public:	// constructors

	CTPSLSimple()			:	CTPSLBase()							{	Init();	}
	CTPSLSimple(string symbol, ENUM_TIMEFRAMES timeframe)
								:	CTPSLBase(symbol, timeframe)	{	Init();	}
	~CTPSLSimple()														{	}
	
	int			Init();

public:

	virtual void	SetIndex(int index)					{	mIndex	=	index;	}
	virtual double	GetIndex()								{	return(mIndex);			}

	virtual void	SetMultiplier(double multiplier)	{	mMultiplier	=	multiplier;	}
	virtual double	GetMultiplier()						{	return(mMultiplier);			}

	virtual double	GetTakeProfit()						{	return(GetValue());			}
	virtual double	GetStopLoss()							{	return(GetValue());			}

};

int		CTPSLSimple::Init() {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	mMultiplier	=	1.0;
	
	return(INIT_SUCCEEDED);
	
}

double	CTPSLSimple::GetValue() {

	double	value	=	0;//GetIndicatorData(0, mIndex)*mMultiplier;

	return(value);
	
}

	
