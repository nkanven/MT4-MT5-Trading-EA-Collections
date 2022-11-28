/*
 	Trade.mqh
 	(For MQL4)
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
*/
 
#include	"../CommonBase.mqh"

enum ENUM_POSITION_TYPE {
	POSITION_TYPE_BUY		=	ORDER_TYPE_BUY,
	POSITION_TYPE_SELL	=	ORDER_TYPE_SELL
};

class CTradeCustom : public CCommonBase {

private:

protected:	// member variables

   int             mMagic;                // expert magic number

public:	// constructors

	CTradeCustom();
	~CTradeCustom();
	
public:

	ulong		RequestMagic()										{ return(mMagic);	}
	void		SetExpertMagicNumber(const int magic)		{ mMagic=magic;	}
	
	double	BuyPrice(string symbol)		{	return(SymbolInfoDouble(symbol, SYMBOL_ASK));	}
	double	SellPrice(string symbol)	{	return(SymbolInfoDouble(symbol, SYMBOL_BID));	}

	bool		Buy(const double volume,const string symbol=NULL,double price=0.0,const double sl=0.0,const double tp=0.0,const string comment="");
	bool		Sell(const double volume,const string symbol=NULL,double price=0.0,const double sl=0.0,const double tp=0.0,const string comment="");

	bool		PositionCloseByType(const string symbol, ENUM_POSITION_TYPE positionType,const int deviation=ULONG_MAX);

};

CTradeCustom::CTradeCustom() {

	mMagic	=	0;
	
}

CTradeCustom::~CTradeCustom() {

}

bool		CTradeCustom::Buy(const double volume,const string symbol=NULL,double price=0.0,const double sl=0.0,const double tp=0.0,const string comment="") {
	if (price==0.0)	price	=	BuyPrice(symbol);
	int	ticket	=	OrderSend(symbol, ORDER_TYPE_BUY, volume, price, 0, sl, tp, comment, mMagic);
	return(ticket>0);
}

bool		CTradeCustom::Sell(const double volume,const string symbol=NULL,double price=0.0,const double sl=0.0,const double tp=0.0,const string comment="") {
	if (price==0.0)	price	=	SellPrice(symbol);
	int	ticket	=	OrderSend(symbol, ORDER_TYPE_SELL, volume, price, 0, sl, tp, comment, mMagic);
	return(ticket>0);
}

bool		CTradeCustom::PositionCloseByType(const string symbol, ENUM_POSITION_TYPE positionType, const int deviation=ULONG_MAX) {

	int	slippage	=	(deviation==ULONG_MAX) ? 0 : deviation;
	
	bool	result	=	true;
	int	cnt		=	OrdersTotal();
	for (int i = cnt-1; i>=0; i--) {
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
			if (OrderSymbol()==symbol && OrderMagicNumber()==mMagic && OrderType()==positionType) {
				result	&=	OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage);
			}
		}
	}

	return(result);
	
}
