/**
 * Created by Saravana
 * - This class implements the CalcAccountScoreInterface make use of the signature method CalcAccountScore which will provide the account 
 * record details and mode from custom settings.
 * - This class to calculate only for mode Constants.DEFAULT and Constants.ADVANCE
 */

public with sharing class CalcAccountScorePackage implements CalcAccountScoreInterface{

    /**
     * The interface class signature method body is defined. Calculation is happening based on the value of param.mode variable  
     */
    public Decimal CalcAccountScore(CalcAccountScoreHandler.Parameter param){
        Decimal accountScoreValue;
        Decimal advanceCalcFielValue = (decimal)param.accountRecord.get(param.fieldName);
        try{
            if(param.mode == Constants.DEFAULT_CALC){
                accountScoreValue = CalcAccountScoreLogic(param.accountRecord.AnnualRevenue);
            }else if(param.mode == Constants.ADVANCE){
                accountScoreValue = CalcAccountScoreLogic(advanceCalcFielValue);
            }
        }catch(Exception e){
            throw new AccountScoreException(e.getMessage());
        }
        return accountScoreValue;
    }

    /**
     * This method holds standard account score calculation logic 
     * @param{accRevenueValue} - pass the account revenue value from the any account field 
     */
    private Decimal CalcAccountScoreLogic(Decimal accRevenueValue){
        return (accRevenueValue / 10);
    }
}
