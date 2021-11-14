/*

   EA_Template.mqh

   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com

	Description: Holds common template code between MQ4 and MQ5
	Uses: framework_2.02 minimum
	
*/

//
//	This is where we pull in the framework
//
#include <Nkanven/Frameworks/Framework.mqh>

//
//	Input Section
//

//
//	Some standard inputs,
//		remember to change the default magic for each EA
//
input	double	InpVolume		=	0.01;			//	Default order size
input	string	InpComment		=	__FILE__;	//	Default trade comment
input	int		InpMagicNumber	=	20202020;	//	Magic Number

//
//	Declare the expert, use the child class name
//	If the base class does everything needed then it's OK to
//		just use CExpertBase
//	Declare the name CExpert as the actual class name.
//		This allows other files to just refer to CExpert
//
#define	CExpert	CExpertBase
CExpert		*Expert;

//
//	Indicators - use the child class name instead of CIndicatorBase
//	Remove if not needed
//
CIndicatorBase	*Indicator1;

//
//	Signals - use the child class name instead of CSignalBase
//	Remove if not needed
//
CSignalBase	*EntrySignal;
CSignalBase	*ExitSignal;

//
//	TPSL - use child class names instead of CTPSLBase
//	Remove if not needed
//
CTPSLBase	*TPObject;
CTPSLBase	*SLObject;

//
//	Indicators for TPSL - use child class names instead of CIndicatorBase
//	Remove if not needed
//
CIndicatorBase	*IndicatorTPSL1;
CIndicatorBase	*IndicatorTPSL2;

int OnInit() {

	//
	//	Instantiate the expert
	//		Uses the declared class name
	//
	Expert	=	new CExpert();

	//
	//	Assign the default values to the expert
	//
	Expert.SetVolume(InpVolume);
	Expert.SetTradeComment(InpComment);
	Expert.SetMagic(InpMagicNumber);
	
	//
	//	Create the indicators - using your child class name
	//
	Indicator1	=	new CIndicatorBase();
	
	//
	//	Set up the signals - using your child class names
	//
	EntrySignal	=	new CSignalBase();
	EntrySignal.AddIndicator(Indicator1, 0);	//	Add as many indicators as you need
	
	ExitSignal	=	new CSignalBase();
	ExitSignal.AddIndicator(Indicator1, 0);	//	Add as many indicators as you need

	//
	//	Add the signals to the expert
	//
	Expert.AddEntrySignal(EntrySignal);	//	repeat for more signals
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
	
	
	//	Delete all objects created
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

