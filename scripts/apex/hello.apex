// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


Set<String> fieldAPIName = new Set<String>{
    'Name'
};
Id accId = '0010K00002KVDaYQAX';
Decimal accountScoreVal = CalcAccountScoreHandler.runAccountScoreCalcWithSpecificAccountFields(accId, fieldAPIName);
system.debug(' accountScoreVal ->>>>>>>>> ' +accountScoreVal);

Id accId = '0016D00000R173TQAR';
Decimal accountScoreVal = CalcAccountScoreHandler.runAccountScoreCalc(accId);
system.debug(' accountScoreVal ->>>>>>>>> ' +accountScoreVal);

List<Company__c> companyRecord = new List<Company__c>();
SObjectType scheduleType = companyRecord.getSObjectType();
system.debug(' scheduleType ->>>>>>>>> ' +scheduleType);

system.debug('aura -> '+ [SELECT Id, DeveloperName, NamespacePrefix FROM AuraDefinitionBundle ]);
Map<String, AuraDefinitionBundle> auraComps = new Map<String, AuraDefinitionBundle>();
            
for(AuraDefinitionBundle auraDef : [SELECT Id, DeveloperName, NamespacePrefix FROM AuraDefinitionBundle 
    WHERE Type = 'Component']){
    auraComps.put(auraDef.DeveloperName, auraDef);
}
system.debug(' auraComps ->>>>>>>>> ' +auraComps);

Account_Score_Calculation_Configuration__c modeCustomSetting = Account_Score_Calculation_Configuration__c.getInstance(UserInfo.getUserId());
system.debug(' modeCustomSetting User #### ' +modeCustomSetting);


Map<String, Schema.SObjectField> accountObjSchemaFieldMap = Schema.SObjectType.Account.fields.getMap();
for(String fieldName: accountObjSchemaFieldMap.keySet()){
    Schema.DisplayType fieldType = accountObjSchemaFieldMap.get(fieldName).getDescribe().getType();
    if(fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY || fieldType == Schema.DisplayType.INTEGER){
            System.debug('------> fieldName <------- '+ fieldName +' ------> fieldType <------- '+ fieldType);
    }
}

String mode = 'Default';
switch on mode {
    when 'Default' {
        accountScoreValue = calcAccountScoreLogic(param.accountRecord.AnnualRevenue);
    }
    when 'Advance' {
        accountScoreValue = calcAccountScoreLogic(param.accountRecord.sk14__Custom_Field1__c);
    }
}