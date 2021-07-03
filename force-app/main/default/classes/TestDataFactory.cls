@isTest
public with sharing class TestDataFactory {
    /**
     * Account Creation for test data
     */
    public static Account accountCreation() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.AnnualRevenue = 1000;
        acc.BillingStreet = 'Str 2';
        acc.BillingState = 'North Holland';
        acc.BillingCity = 'Amsterdam';
        acc.BillingCountry = 'Netherlands';
        acc.BillingPostalCode = '1017 CJ';
        //acc.Custom_Field1__c = 2000;
        //acc.Account_Revenue_Custom_Imp__c = 2500;
        insert acc;

        return acc;
    }

    /**
     * Custom setting creation for test data
     * @param{mode} - pass the  account score calculation mode
     * @param{apexClass} - pass the apex class name for custom mode calculation
     */
    /*public static void modeCustomDettingCreation(String mode, String apexClass) {
        Account_Score_Calculation_Configuration__c modeCustomDetting = new Account_Score_Calculation_Configuration__c();
        modeCustomDetting.Mode__c = mode;
        modeCustomDetting.Apex_Class_Name__c = String.isNotBlank(apexClass) ? apexClass : '';
        insert modeCustomDetting;
    }*/

    /**
     * User Creation for test data
     * @param{profName} - pass the profile name
     * @param{email} - pass the email addres
     */
    public static User createUser(String profName, String email){
        Profile p = [SELECT Id FROM Profile WHERE Name=: profName];
        String uniqueUserName = 'userName' + DateTime.now().getTime() + '@DevUserName.com';
        
        User u = new User(Alias = 'devUser', Email= email,
            EmailEncodingKey='UTF-8', LastName='Dev', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName);
        insert u;

        return u;
    }

    /**
     * Query User for test data
     * @param{aliasName} - pass the user alias name
     */
    public static User queryUserBasedOnAlias(String aliasName){
        return [Select Id FROM User WHERE Alias =:aliasName LIMIT 1];
    }

    /***
     * Supplier Creation
     */

    public static Supplier__c supplierCreation(integer i) {
        Supplier__c supp = new Supplier__c();
        supp.Name = 'Test '+ i;
        supp.City__c = 'Amsterdam';
        supp.Country__c = '';
        supp.State__c = 'North Holland';
        supp.Street__c = 'Herengracht 574';
        supp.PostalCode__c = '1017 CJ';

        return supp;
    }

    /***
     * Case Creation
     */

    public static Case caseCreation(Integer i, Id accId) {
        Case cas = new Case();
        cas.Subject = 'Test '+ i;
        cas.AccountId = accId;
        cas.Status = 'New';
        return cas;
    }
}
