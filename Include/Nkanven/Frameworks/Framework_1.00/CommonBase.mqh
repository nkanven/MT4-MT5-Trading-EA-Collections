/*
 	CommonBase.mqh
 	For framework version 1.0
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
class CCommonBase {

private:

protected:	//	Members

	int					mDigits;
	string				mSymbol;
	ENUM_TIMEFRAMES	mTimeframe;
	
	string				mInitMessage;
	int					mInitResult;

protected:	//	Constructors

	//
	//	Constructors
	//
	CCommonBase()														{	Init(_Symbol,	(ENUM_TIMEFRAMES)_Period);		}
	CCommonBase(string symbol)										{	Init(symbol,	(ENUM_TIMEFRAMES)_Period);		}
	CCommonBase(int timeframe)										{	Init(_Symbol,	(ENUM_TIMEFRAMES)timeframe);	}
	CCommonBase(ENUM_TIMEFRAMES timeframe)						{	Init(_Symbol,	timeframe);							}
	CCommonBase(string symbol, int timeframe)					{	Init(symbol,	(ENUM_TIMEFRAMES)timeframe);	}
	CCommonBase(string symbol, ENUM_TIMEFRAMES timeframe)	{	Init(symbol,	timeframe);							}

	//
	//	Destructors
	//
	~CCommonBase()	{};
	
	int					Init(string symbol, ENUM_TIMEFRAMES timeframe);

protected:	//	Functions

	int					InitError(string initMessage, int initResult)
																			{	mInitMessage = initMessage;
																				mInitResult = initResult;
																				return(initResult);	}
	
public:	//	Properties

	int					InitResult()								{	return(mInitResult);									}
	string				InitMessage()								{	return(mInitMessage);								}
	
public:	//	Functions

	bool					TradeAllowed()								{	return(SymbolInfoInteger(mSymbol, SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_DISABLED);	}
	
};

int	CCommonBase::Init(string symbol, ENUM_TIMEFRAMES timeframe) {

	InitError("", INIT_SUCCEEDED);
	
	mSymbol			=	symbol;
	mTimeframe		=	timeframe;
	mDigits			=	(int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	
	return(INIT_SUCCEEDED);
	
}

