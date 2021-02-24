@isTest
public with sharing class CaseSatisfactionAvgCalcTest {
    @testSetup
    static void testDataSetup(){
        Account acc = TestDataFactory.accountCreation();

        List<Case> listCase = new List<Case>();
        for(Integer i = 0; i < 10; i++){
            Case cs = TestDataFactory.caseCreation(i, acc.Id);
            listCase.add(cs);
        }

        if(listCase.size() > 0){
            insert listCase;
        }
    }

    /**
     * Case update scenario
     */
    @isTest
    static void runCalcAvgRatingUpdateTest(){
        List<Case> listCase = new List<Case>();
        Test.startTest();
        for(Case cs : [Select Id, Rating__c, Status FROM Case]){
            cs.Rating__c = 4;
            cs.Status = 'Closed';
            listCase.add(cs);
        }

        if(listCase.size() > 0){
            update listCase;
        }
        Test.stopTest();

        System.assertEquals(4, [Select Id, Avg_Rating__c FROM Account LIMIT 1].Avg_Rating__c);
    }

    /**
     * Case Delete scenario
     */
    @isTest
    static void runCalcAvgRatingDeleteTest(){
        List<Case> listCase = new List<Case>();

        Test.startTest();
        delete [Select Id, Rating__c, Status FROM Case];
        Test.stopTest();

        System.assertEquals(null, [Select Id, Avg_Rating__c FROM Account LIMIT 1].Avg_Rating__c);
    }
}
