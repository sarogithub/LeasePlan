global with sharing class TriggerHandlerFactory {
    global static Map<String, TriggerHandlerFactory> handlerMap = new Map<String, TriggerHandlerFactory>();
    private Map<String, String> triggerClasses = new Map<String, String>();
    private static Map<String, List<TriggerConfiguration__mdt>> configMap = new Map<String, List<TriggerConfiguration__mdt>>();

    static{
        for(TriggerConfiguration__mdt trig : [SELECT Class__c, SObject__c, Order__c, TriggerEvent__c, NamespacePrefix
            FROM TriggerConfiguration__mdt
            WHERE isActive__c = true
            ORDER BY SObject__c, TriggerEvent__c, Order__c]){

            String key = (String.isNotBlank(trig.NamespacePrefix) && trig.SObject__c.contains('__c'))
                ? trig.NamespacePrefix+'__'+trig.SObject__c+'-'+trig.TriggerEvent__c
                : trig.SObject__c+'-'+trig.TriggerEvent__c;
            if(configMap.get(key)==null){
                configMap.put(key, new List<TriggerConfiguration__mdt>());
            }
            configMap.get(key).add(trig);
        }
    }

    global static void run(System.TriggerOperation event) {
        SObjectType soType = (Trigger.isDelete) ? Trigger.old[0].getSObjectType() : Trigger.new[0].getSObjectType();
        String sObjectEvent = soType + '-' + event;
        if (handlerMap.get(sObjectEvent) == null) {
            handlerMap.put(sObjectEvent, new TriggerHandlerFactory(sObjectEvent, soType));
        }
        handlerMap.get(sObjectEvent).execute();
    }

    private TriggerHandlerFactory(String sObjectEvent, SObjectType soType) {
        if(configMap.get(sObjectEvent)!=null){
            for (TriggerConfiguration__mdt var : configMap.get(sObjectEvent)) {
                if(soType == Utils.getObjectWithNamespace(var.SObject__c)){
                    triggerClasses.put(var.Class__c, var.NamespacePrefix);
                }
            }
        }
    }

    private void execute() {
        ITriggerHandler handler;
        TriggerHandlerFactory.Parameter param = new TriggerHandlerFactory.Parameter();
        param.NewSObjects = Trigger.new;
        param.OldSObjectsMap = Trigger.oldMap;
        if(!triggerClasses.isEmpty()){
            for (String cName : triggerClasses.keySet()) {
                handler = getInstance(triggerClasses.get(cName), cName);
                handler.process(param); 
            }
        }
    }

    private ITriggerHandler getInstance(String namespace, String className) {
        ITriggerHandler handler;
        Type cType = (String.isNotBlank(namespace)) ? Type.forName(namespace, className) : Type.forName(className);
        if (cType == null) {
            throw new TriggerServiceException('Error Found in Trigger Handler');
        }
        try {
            handler = (ITriggerHandler) cType.newInstance();
        } catch (Exception e) {
            throw new TriggerServiceException('Error Found in Trigger Handler');
        }
        return handler;
    }

    global class Parameter {
        global List<SObject> NewSObjects {get; set;}
        global Map<Id, SObject> OldSObjectsMap {get; set;}
    }

    global class TriggerServiceException extends Exception {}
}
