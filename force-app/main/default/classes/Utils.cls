/**
 * Created by Saravana
 * This class holds the reusable methods
 */

public with sharing class Utils {
    /**
     * sObject type schema
     */
    public static Map<String,SObjectType> sObjectTypeMap = Schema.getGlobalDescribe();

    /**
     * Join set of string with comma delimiter 
     */
    public static String JoinSetOfString(Set<String> setOfString){
        return ((setOfString.size() > 0) ? String.join((Iterable<String>)setOfString, ', ') : NULL);
    }

    /** 
     * get all the fieldsets based on the sObject Name - 
     */
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }

    /** 
     * get all the fields based on the sObject Name - 
     */
    public static Map<String, Schema.SObjectField> getSobjectFieldsMap(String sObjectName) {
        Map<String, Schema.SObjectField> fieldLocalNameMap = new Map<String, SObjectField>();
        Map<String, Schema.SObjectField> fieldMap = sObjectTypeMap.get(String.valueOf(sObjectName)).getDescribe().fields.getMap();
        for (String field : fieldMap.keySet()){
            Schema.SObjectField soField = fieldMap.get(field);
            fieldLocalNameMap.put(soField.getDescribe().getLocalName(), soField);
        }
        return fieldLocalNameMap;
    }

    /** 
     * get all the fields based on the sObject Name - 
     */
    public static Map<String, String> getSobjectFieldsApiToLabelMap(String sObjectName) {
        Map<String, String> fieldLocalNameToLabelMap = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldMap = sObjectTypeMap.get(String.valueOf(sObjectName)).getDescribe().fields.getMap();
        for (String field : fieldMap.keySet()){
            Schema.SObjectField soField = fieldMap.get(field);
            fieldLocalNameToLabelMap.put(soField.getDescribe().getLocalName(), soField.getDescribe().getLabel());
        }
        return fieldLocalNameToLabelMap;
    }

    /**
     * get all the fields based on the sObject Name - Namespace API Name 
     */
    public static Map<String, Schema.SObjectField> getSobjectFieldsMapWithNameSpace(String sObjectName) {
        Map<String, Schema.SObjectField> fieldLocalNameMap = new Map<String, SObjectField>();
        Map<String, Schema.SObjectField> fieldMap = sObjectTypeMap.get(String.valueOf(sObjectName)).getDescribe().fields.getMap();
        for (String field : fieldMap.keySet()){
            Schema.SObjectField soField = fieldMap.get(field);
            fieldLocalNameMap.put(soField.getDescribe().getName(), soField);
        }
        return fieldLocalNameMap;
    }

    /**
     * get ObjectType with Namespace
     */
    public static Schema.SObjectType getObjectWithNamespace(String sObjectName){
        List<Schema.DescribeSObjectResult> sObjResults = Schema.describeSObjects(new List<String>{sObjectName});
        return sObjResults[0].getSObjectType();
    }

    /**
     * get Aura definition to check the namespace of the component
     */
    public static Map<String, AuraDefinitionBundle>  getAuraDefinitions(){
        Map<String, AuraDefinitionBundle> auraComps = new Map<String, AuraDefinitionBundle>();
        for(AuraDefinitionBundle auraDef : [SELECT Id, DeveloperName, NamespacePrefix FROM AuraDefinitionBundle]){
            auraComps.put(auraDef.DeveloperName, auraDef);
        }

        return auraComps;
    }
}
