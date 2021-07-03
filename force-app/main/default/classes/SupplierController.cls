public with sharing class SupplierController {
    @AuraEnabled( cacheable = true )  
    public static String fetchSupplier(String inputArg) {  

        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, String> requestParametersMap = (Map<String, String>)JSON.deserialize(inputArg, Map<String, String>.class);

        if(requestParametersMap.containsKey('recordId') && requestParametersMap.containsKey('searchKey')){
            String accId = requestParametersMap.get('recordId');
            String searchKey = requestParametersMap.get('searchKey');

            Account acc = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, BillingAddress__c 
                            FROM Account WHERE Id =: accId];
            outputMap.put('account', acc);
            String city = acc.BillingCity;

            String str = 'SELECT Id, Name, Street__c, City__c, State__c, Country__c, PostalCode__c, Address__c';
            str += ' FROM Supplier__c WHERE City__c =: city';
            if(string.isNotBlank(searchKey)){
                str += ' AND Name like \''+ searchKey + '%\' ';
            } 
            List<Supplier__c> supplierList = Database.query(str);
            outputMap.put('supplierList', supplierList);

            Map<String, String> supplierObjFieldApiToLabelMap = Utils.getSobjectFieldsApiToLabelMap('Supplier__c');
            outputMap.put('supplierObjFieldApiToLabelMap', supplierObjFieldApiToLabelMap);

            List<String> supplierObjFieldSetFields  = new List<String>();
            for(Schema.FieldSetMember fieldSetMemberObj : Utils.readFieldSet('SuppliersList','Supplier__c')){
                supplierObjFieldSetFields.add(fieldSetMemberObj.getFieldPath());
            }
            outputMap.put('supplierObjFieldSetFields', supplierObjFieldSetFields);
        }

        return JSON.serialize(outputMap);
    }
}
