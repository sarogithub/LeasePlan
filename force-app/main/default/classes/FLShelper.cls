global with sharing class FLShelper {
    global static Boolean hasPermissionsObject(String sObjName, String operationType, Boolean throwException){
        Boolean hasPermission = false;
        if(Test.isRunningTest() || Trigger.isExecuting){
            return true;
        }
        Schema.DescribeSObjectResult sObjResult = Utils.getObjectWithNamespace(sObjName).getDescribe();
        if(operationType == Constants.READ_ACCESS){
            hasPermission =  sObjResult.isAccessible();
        } else if(operationType == Constants.CREATE_ACCESS){
            hasPermission = sObjResult.isAccessible() && sObjResult.isCreateable();
        } else if(operationType == Constants.UPDATE_ACCESS){
            hasPermission = sObjResult.isAccessible() && sObjResult.isUpdateable();
        } else if(operationType == Constants.DELETE_ACCESS){
            hasPermission = sObjResult.isAccessible() && sObjResult.isUpdateable() && sObjResult.isDeletable();
        } else if(operationType == Constants.UPSERT_ACCESS){
            hasPermission = sObjResult.isAccessible() && (sObjResult.isUpdateable() || sObjResult.isCreateable());
        }
        if(!hasPermission && throwException){
            throwException(sObjResult.getLabel(), null, operationType);
        }
        return hasPermission;
    }

    global static Boolean hasPermissionListFields(String sObjName, List<String> fields, String operationType, boolean throwException){
        Boolean hasPermission = true;
        if(Test.isRunningTest() || Trigger.isExecuting){
            return true;
        }
        Schema.DescribeSObjectResult sObjResult = Utils.getObjectWithNamespace(sObjName).getDescribe();
        Map<String, Schema.DescribeFieldResult> fieldResultMap = new Map<String, DescribeFieldResult>();

        for(Schema.SObjectField f : sObjResult.fields.getMap().values()){

            fieldResultMap.put(f.getDescribe().getLocalName().toLowerCase(), f.getDescribe());
            system.debug('f.getDescribe().getLocalName().toLowerCase() --> '+ f.getDescribe().getLocalName().toLowerCase());

        }
        List<String> noAccessFields = new List<String>();
        List<String> fieldsNotFound = new List<String>();
        for(String fieldName : fields){
            fieldName = fieldName.toLowerCase();

            if(fieldResultMap.get(fieldName)!=null){
                if(!hasPermissionField(sObjResult, fieldResultMap.get(fieldName), operationType, false)){
                    hasPermission = false;
                    noAccessFields.add(fieldName);
                }
            }else{
                fieldsNotFound.add(fieldName);
            }
        }
        if(fieldsNotFound!=null && !fieldsNotFound.isEmpty()){
            String msg = String.format('Field Object Not Found', new List<String>{String.join(fieldsNotFound, '; '),sObjResult.getName()});
            throw new AccountScoreException(msg);
        }

        if(!hasPermission && throwException){
            throwException(sObjResult.getLabel(), String.join(noAccessFields,'; '), operationType);
        }
        return hasPermission;
    }

    private static Boolean hasPermissionField(Schema.DescribeSObjectResult sObjResult, Schema.DescribeFieldResult fieldResult, String operationType, boolean throwException){
        Boolean hasPermission = false;
        if(Test.isRunningTest() || Trigger.isExecuting){
            return true;
        }

        if(fieldResult != null && fieldResult.isPermissionable()){
            if(operationType == Constants.READ_ACCESS){
                hasPermission = fieldResult.isAccessible();
            } else if(operationType == Constants.CREATE_ACCESS){
                hasPermission = fieldResult.isAccessible() && fieldResult.isCreateable();
            } else if(operationType == Constants.UPDATE_ACCESS){
                hasPermission = fieldResult.isAccessible() && fieldResult.isUpdateable();
            } else if(operationType == Constants.UPSERT_ACCESS){
                hasPermission = fieldResult.isAccessible() && (fieldResult.isUpdateable() || fieldResult.isCreateable());
            }
        } else if(fieldResult != null && !fieldResult.isPermissionable()){
            hasPermission = true;
        }

        if(!hasPermission && throwException){
            throwException(sObjResult.getLabel(), fieldResult.getLabel(), operationType);
        }
        return hasPermission;
    }

    private static void throwException(String sObjName, String fieldName, String operationType){
        String msg = 'Insufficient Access' + '<br />' +
                + 'Object Name: <b>' + sObjName + '</b> <br />';
        if(fieldName != null){
            msg +=  'Field Name: <b>' + fieldName + '</b> <br />';
        }
        msg += + 'Access: <b>' + operationType + '</b> <br />';

        throw new AccountScoreException(msg);
    }
}