/**
 * Created by Saravana
 * This is the acount score calculator handler which will calc the score based on the account fields and mode and apex class (if custom imp) 
 * from custom setting .
 */

public with sharing class CalcAccountScoreHandler {
    private Account_Score_Calculation_Configuration__c modeCustomSetting;
    private static CalcAccountScoreHandler clsInst = new CalcAccountScoreHandler();

    /**
     * @param{accountId} - Pass 15- or 18-digit salesforce record id an account - mandatory
     *  This method will query all CURRENCY, INTEGER and DOUBLE data type account fields and return in Parameter.accountRecord variable 
     *  to the implements class for processiing 
     */
    public static Decimal runAccountScoreCalc(Id accountId) {
        if(accountId == null){
            throw new AccountScoreException(Label.AccountIdIsMandatoryMessage);
        }

        // Passing emapty set of string to the second argument as the fetchAccount method will query all fields
        Account accRecord = clsInst.fetchAccount(accountId, new Set<String>());
        Decimal accountScoreVal;
        if(accRecord != null) {
            accountScoreVal = clsInst.execute(accRecord);
        }
        return accountScoreVal;
    }

    /**
     * This method will query all CURRENCY, INTEGER and DOUBLE data type account fields and return in Parameter.accountRecord variable 
     *  to the implements class for processiing
     */
    private Set<String> queryAllFieldsInAccountsObject(){
        Map<String, Schema.SObjectField> accountObjSchemaFieldMap = Utils.getSobjectFieldsMap('Account');
        Set<String> setOfAccountFields = new Set<String>();
        for(String fieldName: accountObjSchemaFieldMap.keySet()){
            switch on accountObjSchemaFieldMap.get(fieldName).getDescribe().getType() {
                when DOUBLE, CURRENCY, INTEGER {
                    setOfAccountFields.add(fieldName);
                }
            }
        }
        
        return setOfAccountFields; 
    }   
    
    /**
     * This methjod to query the account the record based on the below parameters
     * @param{accountId} - Pass 15- or 18-digit salesforce record id an account - mandatory
     * @param{fieldAPINameToQuery} - set of account field API name for dynamic query - optional
     * @param{hasAllAccountFields} - pass true or false based if all accounts fields going to be queried
     */
    private Account fetchAccount(Id accountId, Set<String> fieldAPINameToQuery){
        String accQuery = 'SELECT Id ' ;
        accQuery += ', ' + ((!fieldAPINameToQuery.isEmpty()) ? Utils.JoinSetOfString(fieldAPINameToQuery) : Utils.JoinSetOfString(clsInst.queryAllFieldsInAccountsObject()));
        accQuery += ' FROM Account WHERE Id =: AccountId LIMIT 1';

        List<Account> accountRecord = Database.query(accQuery); 
        if(accountRecord.size() <= 0)
            return null;

        return accountRecord[0];
    } 

    /**
     * This method will execute the account score calculation logic based on mode defined in hierarchical custom setting for the user or profile
     * @param{accountId} - Pass 15- or 18-digit salesforce record id an account - mandatory
     */
    private Decimal execute(Account accountRecord) {
        CalcAccountScoreInterface handler;
        modeCustomSetting = Account_Score_Calculation_Configuration__c.getInstance(UserInfo.getUserId());
        CalcAccountScoreHandler.Parameter param = new CalcAccountScoreHandler.Parameter();

        param.accountRecord = accountRecord;

        // Mode is very important for account score calculation, if not present the calculation will happen on Default mode
        if(modeCustomSetting.Mode__c != null){
            param.mode = modeCustomSetting.Mode__c;

            if(param.mode == Constants.DEFAULT_CALC){
                handler = getInstance(Constants.PACKAGE_CLASS_NAME);
            }else if(param.mode == Constants.ADVANCE){
                handler = getInstance(Constants.PACKAGE_CLASS_NAME);
                param.fieldName = modeCustomSetting.Field_API_Name__c;
            }else if(param.mode == Constants.CUSTOM){
                // Apex Class Name is mandatory for Custom mode calculation
                //if(String.isBlank(modeCustomSetting.Apex_Class_Name__c))
                    //throw new accountScoreException(Label.ApexClassNameIsMandatoryForCustomModeMsg);
                handler = getInstance(modeCustomSetting.Apex_Class_Name__c);
            }
        }else{
            // When no custom setting is defined, the calculation will happen on Default mode  
            param.mode = Constants.DEFAULT_CALC;
            handler = getInstance(Constants.PACKAGE_CLASS_NAME);
        }

        return handler.CalcAccountScore(param);
    }

    /**
     * Create instanse dynamically for the apex class defined in the custom settings
     */
    private CalcAccountScoreInterface getInstance(String className) {
        CalcAccountScoreInterface handler;
        Type cType = (String.isNotBlank(className)) ? Type.forName(className) : null;
        handler = (CalcAccountScoreInterface) cType.newInstance();
        return handler;
    } 
    
    /**
     * Inner class to store the account record and calculation mode
     */
    public class Parameter {
        public Account accountRecord {get; set;}
        public String mode {get; set;}
        public String fieldName {get; set;}
    }   
}
