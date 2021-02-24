/**
 * Created by Saravana
 * This class helps the component to render the company fields dynamically and inthe configured custom component format
 * It resolves the binds Namespace with field API name and custom components configured in custom metadata 
 */

public with sharing class CompanyController {
    @AuraEnabled
    public static Map<String, Object> getCompanyRecords() {
        try {
            Map<String, Object> outputMap = new Map<String, Object>();
            List<Field_and_Its_Visibility_Type__mdt> lstOfFieldCustomMetadata = new List<Field_and_Its_Visibility_Type__mdt>();
            SObjectType lstOfFieldCustomMetadataObjType = lstOfFieldCustomMetadata.getSObjectType();

            // FLS for Field_and_Its_Visibility_Type__mdt custom metadata
            FLShelper.hasPermissionsObject(String.valueOf(lstOfFieldCustomMetadataObjType), Constants.READ_ACCESS, true);
            List<String> customMetadataFields = new List<String>{
                'Component_Type__c', 'Field_API_Name__c', 'Show_On_Screen__c', 'Order_of_Fields_to_Display__c'
            };
            FLShelper.hasPermissionListFields(String.valueOf(lstOfFieldCustomMetadataObjType), customMetadataFields, Constants.READ_ACCESS, true);

            Set<String> fieldAPINames = new Set<String>(); // with NamespacePrefix - used for aura component redering 
            Set<String> fieldNames = new Set<String>(); //  without NamespacePrefix - used for query

            List<Company__c> companyRecord = new List<Company__c>();
            SObjectType companyObjType = companyRecord.getSObjectType();
            Map<String, Schema.SObjectField> companyFieldMap = Utils.getSobjectFieldsMap(String.valueOf(companyObjType)); // Field map without namespace
            Map<String, Schema.SObjectField> companyFieldMapWithNamespace = Utils.getSobjectFieldsMapWithNameSpace(String.valueOf(companyObjType)); // Field map with namespace

            //get Aura definition to check the namespace of the component
            Map<String, AuraDefinitionBundle> auraComps = Utils.getAuraDefinitions();
            
            for(Field_and_Its_Visibility_Type__mdt customMetadata : [SELECT Id, Component_Type__c, Field_API_Name__c,
                Show_On_Screen__c, NamespacePrefix, Order_of_Fields_to_Display__c
                FROM Field_and_Its_Visibility_Type__mdt WHERE Show_On_Screen__c = TRUE AND Field_API_Name__c <> NULL AND 
                Component_Type__c <> NULL
                ORDER BY Order_of_Fields_to_Display__c ASC]){

                    // If field name does not contains namespace in the custom metadata configuration  
                    if(companyFieldMap.containsKey(customMetadata.Field_API_Name__c)){
                        Schema.SObjectField fieldSchema = companyFieldMap.get(customMetadata.Field_API_Name__c);
                        String fieldAPIName = (String)fieldSchema.getDescribe().getName();
                        String fieldLocalName = (String)fieldSchema.getDescribe().getLocalName();

                        customMetadata.Field_API_Name__c = fieldAPIName; // to use the fields in Aura component
                        fieldNames.add(fieldLocalName); // For FLS 
                        fieldAPINames.add(fieldAPIName); // For query

                        if(auraComps.containsKey(customMetadata.Component_Type__c)){
                            customMetadata.Component_Type__c = conCatNamespaceAndCompName(auraComps, customMetadata.Component_Type__c);
                        }
                    }else if(companyFieldMapWithNamespace.containsKey(customMetadata.Field_API_Name__c)){ 
                        // If field name contains namespace in the custom metadata configuration
                        Schema.SObjectField fieldSchemaWithNamespace = companyFieldMapWithNamespace.get(customMetadata.Field_API_Name__c);
                        String fieldAPIName = (String)fieldSchemaWithNamespace.getDescribe().getName();

                        if(auraComps.containsKey(customMetadata.Component_Type__c)){
                            customMetadata.Component_Type__c = conCatNamespaceAndCompName(auraComps, customMetadata.Component_Type__c);
                            fieldAPINames.add(fieldAPIName);
                        }
                    }
                lstOfFieldCustomMetadata.add(customMetadata);
            }

            // FLS for Company__c Object
            FLShelper.hasPermissionsObject(String.valueOf(companyObjType), Constants.READ_ACCESS, true);
            List<String> companyFields = new List<String>();
            companyFields.addAll(fieldNames);
            FLShelper.hasPermissionListFields(String.valueOf(companyObjType), companyFields, Constants.READ_ACCESS, true);

            // Query only the fields configured in the custom metadata
            if(fieldAPINames.size()>0){
                String companyQuery = 'SELECT Id ' ;
                companyQuery += ', ' + ((!fieldAPINames.isEmpty()) ? Utils.JoinSetOfString(fieldAPINames) : '');
                companyQuery += ' FROM Company__c ORDER BY Name ASC';

                companyRecord = Database.query(companyQuery); 
            }
            // This is to take the output aura component
            outputMap.put('companyRecords', companyRecord);
            outputMap.put('fieldsAndCompType', lstOfFieldCustomMetadata);

            return outputMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +' log '+ e.getLineNumber());
        }
    }

    public static String conCatNamespaceAndCompName(Map<String, AuraDefinitionBundle> auraComps, String compType) {
        AuraDefinitionBundle auraDefinition = auraComps.get(compType);
        String namespacePrefix = string.isNotBlank(auraDefinition.NamespacePrefix) ? auraDefinition.NamespacePrefix : 'c';
        return namespacePrefix + ':' + compType;
    }
}
