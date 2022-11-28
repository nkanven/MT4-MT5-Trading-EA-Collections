/*
 	Framework_2.03.mqh
 	
   Copyright 2013-2020, Orchard Forex
   https://www.orchardforex.com
 
 	
*/

//	History
//	1.00 -	First version, not well version controlled
//	2.00 -	Changed framework structure, functionally same as 1.00
// 2.01 -	Added TP and SL
//	2.02 -	Move compound signals into expertbase
//				Templates now use common files between mq4 and mq5
//				MakeMQH batch script also recreates framework.mqh
//	2.03 -	Added macros to CommonBase to standardise init checking
//				Moved base classes up one level and removed unnecessary folders

#ifndef _FRAMEWORK_VERSION_

	#define	_FRAMEWORK_VERSION_		"2.03"
	
	#include "CommonBase.mqh"
	
	#include	"Trade/Trade.mqh"

	#include "IndicatorBase.mqh"
	#include "SignalBase.mqh"
	#include "TPSLBase.mqh"
	
	#include "ExpertBase.mqh"

	#include "../Extensions/AllExtensions.mqh"

#endif
