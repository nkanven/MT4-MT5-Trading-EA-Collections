/*

   EA_Template.mq5

   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com

	Description:
	
*/

#property copyright "Copyright 2012-2020, Orchard Forex"
#property link      "https://www.orchardforex.com"
#property version   "1.00"
#property strict

//
//	This is where we pull in the framework
//
//	Use the following line for the current framework
#include <Orchard/Frameworks/Framework.mqh>
//	Use the following line for a specific framework (replace x.x)
//#include <Orchard/Frameworks/Framework_x.x/Framework.mqh>

//
//	Input Section
//

//
//	Some standard inputs,
//		remember to change the default magic for each EA
//
input	double	InpVolume		=	0.01;			//	Default order size
input	string	InpComment		=	__FILE__;	//	Default trade comment
input	int		InpMagicNumber	=	20200701;	//	Magic Number

//
//	Declare the expert
//
#define	CExpert	CExpertBase
CExpert		*Expert;

//
//	Indicators
//
CIndicatorBase	*Indicator1;

//
//	Signals
//
CSignalBase	*EntrySignal;
CSignalBase	*ExitSignal;

//
//	TPSL - use child class names instead of CTPSLBase
//
CTPSLBase	*TPObject;
CTPSLBase	*SLObject;

//
//	Indicators for TPSL - use child class names instead of CIndicatorBase
//
CIndicatorBase	*IndicatorTPSL1;
CIndicatorBase	*IndicatorTPSL2;



int OnInit() {

	//
	//	Instantiate the expert, use the child class name
	//
	Expert	=	new CExpert();
	
	//
	//	Assign the default values to the expert
	//
	Expert.SetVolume(InpVolume);
	Expert.SetTradeComment(InpComment);
	Expert.SetMagic(InpMagicNumber);
	
	//
	//	Set up the indicators
	//
	Indicator1	=	new CIndicatorBase();
		
	//
	//	Set up the signals
	//
	EntrySignal	=	new CSignalBase();
	EntrySignal.AddIndicator(Indicator1, 0);
	
	ExitSignal	=	new CSignalBase();
	ExitSignal.AddIndicator(Indicator1, 0);
	
	//
	//	Add the signals to the expert
	//
	Expert.AddEntrySignal(EntrySignal);
	Expert.AddExitSignal(ExitSignal);

	//
	//	If using fixed tp and sl set them here in points
	//
	Expert.SetTakeProfitValue(0);
	Expert.SetStopLossValue(0);
		
	//
	//	Set up the Take Profit and Stop Loss objects
	//	Remember to create child class names, not base
	//
	TPObject			=	new CTPSLBase();	//	Create the object
	IndicatorTPSL1	=	new CIndicatorBase();	//	Create an indicator for the tp object
	TPObject.AddIndicator(IndicatorTPSL1, 0);	//	Add the indicator to tp
	//	Set any other properties needed

	//	And for the SL object
	SLObject			=	new CTPSLBase();
	IndicatorTPSL2	=	new CIndicatorBase();
	SLObject.AddIndicator(IndicatorTPSL2, 0);

	Expert.SetTakeProfitObj(TPObject);
	Expert.SetStopLossObj(SLObject);

	//
	// Finish expert initialisation and check result
	//
	int	result	=	Expert.OnInit();
	
   return(result);

}

void OnDeinit(const int reason) {

   EventKillTimer();
	
	delete	Expert;
	delete	ExitSignal;
	delete	EntrySignal;
	delete	Indicator1;
	delete	TPObject;
	delete	SLObject;
	delete	IndicatorTPSL1;
	delete	IndicatorTPSL2;
	
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

void OnTrade() {

	Expert.OnTrade();
	return;

}

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {

	Expert.OnTradeTransaction(trans, request, result);
	return;

}

double OnTester() {

	return(Expert.OnTester());

}

void OnTesterInit() {

	Expert.OnTesterInit();
	return;

}

void OnTesterPass() {

	Expert.OnTesterPass();
	return;

}

void OnTesterDeinit() {

	Expert.OnTesterDeinit();
	return;

}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {

	Expert.OnChartEvent(id, lparam, dparam, sparam);
	return;
	
}

void OnBookEvent(const string &symbol) {

	Expert.OnBookEvent();
	return;

}

