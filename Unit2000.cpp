//---------------------------------------------------------------------------
#include "bcc-testPCH1.h"
#pragma hdrstop
//---------------------------------------------------------------------------
#include "Unit2000.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
Unit2000::Unit2000()
{
}
//---------------------------------------------------------------------------
Unit2000::~Unit2000()
{
}
//---------------------------------------------------------------------------
int Unit2000::Calc(int a, int b)
{
    return a+b * a / b;
}
//---------------------------------------------------------------------------
