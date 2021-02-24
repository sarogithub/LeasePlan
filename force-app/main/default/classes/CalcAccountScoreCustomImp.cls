/**
 * Created by Saravana
 * - This class implements the CalcAccountScoreInterface make use of the signature method CalcAccountScore which will provide the account 
 * record details and mode from custom settings.
 * - This class to calculate only for mode Constants.CUSTOM
 */

public with sharing class CalcAccountScoreCustomImp implements CalcAccountScoreInterface {    
    /**
     * The interface class signature method body is defined. Calculation is happening based on the value of param.mode variable  
     */
    public Decimal CalcAccountScore(CalcAccountScoreHandler.Parameter param){
        Decimal accountScoreValue;

        try{
            accountScoreValue = CalcAccountScoreLogic(param.accountRecord.Account_Revenue_Custom_Imp__c);
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