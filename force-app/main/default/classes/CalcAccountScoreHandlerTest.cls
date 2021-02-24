@isTest
public with sharing class CalcAccountScoreHandlerTest {
    public static User userRecord;

    @testSetup
    static void testDataSetup() {
        TestDataFactory.createUser('Standard User', 'testingUser@dev.com');
    }

    /**
     * Default Mode Test - Positive Secenario
     */
    @isTest
    static void runAccountScoreCalcDefaultModeTest() {
        userRecord = TestDataFactory.queryUserBasedOnAlias('devUser');
        Decimal accountScoreVal;

        System.runAs(userRecord) {
            Account acc = TestDataFactory.accountCreation();
            TestDataFactory.modeCustomDettingCreation(Constants.DEFAULT_CALC, '');
            Test.startTest();
            accountScoreVal = CalcAccountScoreHandler.runAccountScoreCalc(acc.Id);
            Test.stopTest();
        }

        System.assertEquals(100.00, accountScoreVal);
    }

    /**
     * Advance Mode Test - Positive Secenario
     */
    @isTest
    static void runAccountScoreCalcAdvanceModeTest() {
        userRecord = TestDataFactory.queryUserBasedOnAlias('devUser');
        Decimal accountScoreVal;

        System.runAs(userRecord) {
            Account acc = TestDataFactory.accountCreation();
            TestDataFactory.modeCustomDettingCreation(Constants.ADVANCE, '');
            Test.startTest();
            accountScoreVal = CalcAccountScoreHandler.runAccountScoreCalc(acc.Id);
            Test.stopTest();
        }

        System.assertEquals(200.00, accountScoreVal);
    }

    /**
     * Without Custom Settings - Negative Secenario
     */
    @isTest
    static void runAccountScoreCalcWithoutModeTest() {
        userRecord = TestDataFactory.queryUserBasedOnAlias('devUser');
        Decimal accountScoreVal;

        System.runAs(userRecord) {
            Account acc = TestDataFactory.accountCreation();
            Test.startTest();
            accountScoreVal = CalcAccountScoreHandler.runAccountScoreCalc(acc.Id);
            Test.stopTest();
        }

        System.assertEquals(100.00, accountScoreVal);
    }
}
