public with sharing class CaseSatisfactionAvgCalc implements ITriggerHandler {
    List<Case> caseTriggerNewList = new List<Case>();
    Map<Id,Case> caseTriggerOldMap = new Map<Id,Case>();

    public void process(TriggerHandlerFactory.Parameter param) {
        if(param.NewSObjects != null){
            caseTriggerNewList.addAll((List<Case>)param.NewSObjects);
        }

        if(param.OldSObjectsMap != null){
            caseTriggerOldMap.putAll((Map<Id,Case>)param.OldSObjectsMap);
        }

        if(caseTriggerNewList.size() > 0 || caseTriggerOldMap.size() > 0) {
            CaseSatisfactionAvgCalcMethod();
        }
    }

    public void CaseSatisfactionAvgCalcMethod() {
        List<Id> accIds = new List<Id>();
        if(caseTriggerNewList.size() > 0){
            for(Case ics : caseTriggerNewList){
                if(ics.Status == 'Closed'){
                    accIds.add(ics.AccountId);
                }
            }
        }else{
            if(caseTriggerOldMap.size() > 0){
                for(Id icsId : caseTriggerOldMap.keySet()){
                    if(caseTriggerOldMap.get(icsId).Status == 'Closed'){
                        accIds.add(caseTriggerOldMap.get(icsId).AccountId);
                    }
                }
            }
        } 

        if(accIds.size() > 0){
            CaseSatisfactionScoreUpdateInAccount(accIds);
        }
    }

    public static void CaseSatisfactionScoreUpdateInAccount(List<Id> accIds){
        List<Account> accountRecords = new List<Account>();
        List<Id> accountRecordsProcessedId = new List<Id>();

        for(AggregateResult ics : [SELECT AVG(Rating__c) rat, AccountId accId FROM Case 
                           WHERE (Status = 'Closed' AND Rating__c != null AND AccountId IN : accIds) GROUP BY AccountId]){
            Decimal avgRating = (decimal)ics.get('rat'); 
            Id accId = (Id)ics.get('accId');    
            
            Account acc = new Account(
                Id = accId,
                Avg_Rating__c = avgRating.setScale(1)
            );
            
            accountRecords.add(acc);
            accountRecordsProcessedId.add(accId);
        }

        if(accountRecords.size() < accIds.size()){
            for(Id accId : accIds){
                if(!accountRecordsProcessedId.contains(accId)){
                    Account acc = new Account(
                        Id = accId,
                        Avg_Rating__c = null
                    );
                    accountRecords.add(acc);
                }
            }
        }

        if(accountRecords.size() > 0){
            update accountRecords;
        }
    }
}
