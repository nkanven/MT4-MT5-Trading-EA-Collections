/*

   MA Crossover.mq4

   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com

	Description:
	
*/

#property copyright "Copyright 2013-2020, Orchard Forex"
#property link      "https://www.orchardforex.com"
#property version   "1.00"
#property strict

//
//	This is where we pull in the framework
//
#include <Orchard/Frameworks/Framework.mqh>

//
//	Input Section
//
//	Fast moving average
input	int	InpFastPeriods								=	10;	//	Fast periods
input	ENUM_MA_METHOD	InpFastMethod					=	MODE_SMA;	//	Fast method
input	ENUM_APPLIED_PRICE	InpFastAppliedPrice	=	PRICE_CLOSE;	// Fast price

//	Slow moving average
input	int	InpSlowPeriods								=	20;	//	Slow periods
input	ENUM_MA_METHOD	InpSlowMethod					=	MODE_SMA;	//	Slow method
input	ENUM_APPLIED_PRICE	InpSlowAppliedPrice	=	PRICE_CLOSE;	// Slow price

//	Bar numbers for comparison
//input	int	InpBar2										=	2;	//	Base bar number
//input	int	InpBar1										=	1;	//	Crossover bar number

//
//	Some standard inputs,
//		remember to change the default magic for each EA
//
input	double	InpVolume		=	0.01;			//	Default order size
input	string	InpComment		=	__FILE__;	//	Default trade comment
input	int		InpMagicNumber	=	20200701;	//	Magic Number

//
//	Declare the expert, use the child class name
//
#define	CExpert	CExpertBase
CExpert		*Expert;

//
//	Signals, use the child class names if applicable
//
CSignalBase	*EntrySignal;
CSignalBase	*ExitSignal;

//
//	Indicators - use the child class name here
//
CIndicatorMA	*FastIndicator;
CIndicatorMA	*SlowIndicator;

int OnInit() {

	//
	//	Instantiate the expert
	//
	Expert	=	new CExpert();

	//
	//	Assign the default values to the expert
	//
	Expert.SetVolume(InpVolume);
	Expert.SetTradeComment(InpComment);
	Expert.SetMagic(InpMagicNumber);
	
	//
	//	Create the indicators
	//
	FastIndicator	=	new CIndicatorMA(InpFastPeriods, 0, InpFastMethod, InpFastAppliedPrice);
	SlowIndicator	=	new CIndicatorMA(InpSlowPeriods, 0, InpSlowMethod, InpSlowAppliedPrice);
	
	//
	//	Set up the signals
	//
	EntrySignal	=	new CSignalCrossover();
	EntrySignal.AddIndicator(FastIndicator, 0);
	EntrySignal.AddIndicator(SlowIndicator, 0);
	
	//ExitSignal	=	Not needed, using the same signal as entry
	
	//
	//	Add the signals to the expert
	//
	Expert.AddEntrySignal(EntrySignal);
	Expert.AddExitSignal(EntrySignal);	//	Same signal
	
	//
	// Finish expert initialisation and check result
	//
	int	result	=	Expert.OnInit();
	
   return(result);

}

void OnDeinit(const int reason) {

   EventKillTimer();
	
	delete	Expert;
	//delete	ExitSignal;
	delete	EntrySignal;
	delete	FastIndicator;
	delete	SlowIndicator;
	
	return;
	
}

void OnTick() {

	Expert.OnTick();
	return;
	
}

void OnTimer() {

	Expert.OnTimer();
	return;

}

double OnTester() {

	return(Expert.OnTester());

}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {

	Expert.OnChartEvent(id, lparam, dparam, sparam);
	return;
	
}


