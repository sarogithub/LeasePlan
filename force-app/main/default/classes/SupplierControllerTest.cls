@isTest
public with sharing class SupplierControllerTest {
    @testSetup
    static void testDataSetup(){
        TestDataFactory.accountCreation();

        List<Supplier__c> listSupp = new List<Supplier__c>();
        for(Integer i = 0; i < 10; i++){
            listSupp.add(TestDataFactory.supplierCreation(i));
        }

        if(listSupp.size() > 0){
            insert listSupp;
        }
    }

    @isTest
    static void runFetchSupplierTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<String, String> inputString = new Map<String, String>();
        inputString.put('recordId', acc.Id);
        inputString.put('searchKey', 'Test 1');

        String str = SupplierController.fetchSupplier(JSON.serialize(inputString));
    }
}
