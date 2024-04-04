({
    doInit : function(c, e, h) {
        const templateRecordId = c.get('v.templateRecordId');
        const recordId = templateRecordId ? templateRecordId : c.get('v.recordId');
        if(!recordId) {
            // TODO: ERROR Handling
            return;
        }
        h.callAction(c, 'c.getSObjectSummary', {
            recordId : recordId,
            childRelationshipNames : c.get('v.childRelationshipNames'),
            excludedFieldNames: c.get('v.excludedFieldNames')
        })
        .then(h.format)
        .then(function(sObjectSummary){
            console.log(sObjectSummary);
            const clonableFields = [];
            const notClonableFields = [];
            for(let field of sObjectSummary.fields) {
                if(field.isClonable) {
                    clonableFields.push(field);
                } else {
                    notClonableFields.push(field);
                }
            }
            const clonableChildren = [];
            const notClonableChildren = [];
            if(sObjectSummary.children) {
                for(let child of sObjectSummary.children) {
                    if(child.isClonable) {
                        clonableChildren.push(child);
                    } else {
                        notClonableChildren.push(child);
                    }
                }
            }
            if(clonableChildren.length > 20) {
                alert('RecordClone ERROR : CANNOT include more than 20 different child types.');
            }
            c.set('v.clonableChildren', clonableChildren);
            c.set('v.notClonableChildren', notClonableChildren);
            c.set('v.clonableFields', clonableFields);
            c.set('v.notClonableFields', notClonableFields);
            c.set('v.sObjectSummary', sObjectSummary);
            if(sObjectSummary.isNamable) {
                return h.callAction(c, 'c.getNameFieldValue', { 
                    recordId : recordId,
                    objectName : sObjectSummary.apiName,
                    nameField : sObjectSummary.nameField
                });
            } else {
                return Promise.resolve(null);
            }
        })
        .then(function(nameValue) {
            c.set('v.isInitialized', true);
            if(nameValue) {
                c.set('v.newParentRecordName', nameValue);
            }
        })
        .catch(h.handleErrors);
    },    
    onclickClone : function(c, e, h) {
        if (confirm('レコードをコピーします。よろしいですか？') === true) {
            c.set('v.isCloning', true);
            // if templateRecordId is specified, prioritize  it
            const templateRecordId = c.get('v.templateRecordId');
            const recordId = templateRecordId ? templateRecordId : c.get('v.recordId');
            
            h.callAction(c, 'c.execClone', {
                recordId : recordId,
                newParentRecordName : c.get('v.newParentRecordName'),
                childRelationshipNames : c.get('v.childRelationshipNames'),
                excludedFieldNames : c.get('v.excludedFieldNames')
            })
            .then(function(clonedRecord) {
                console.log(clonedRecord);
                if(!clonedRecord) {
                    throw new Error('No Data');
                }
                $A.get('e.force:showToast').setParams({ 
                    'type' : 'success',
                    'title': 'コピー成功',
                    'message': 'レコードをコピーしました'
                }).fire();
                $A.get('e.force:navigateToSObject').setParams({'recordId': clonedRecord.Id}).fire();
                // 20200117 chiba 処理追加 start
                h.callAction(c, 'c.execCloneAfter', {recordId : clonedRecord.Id ,childRelationshipNames : c.get('v.childRelationshipNames')});
                // 20200117 chiba 処理追加 end
            })
            .catch(h.handleErrors)
            .then(function() {
                c.set('v.isCloning', false);
            });
        }
    },
    toggleChildren : function(c, e, h) {
        const currentState = c.get("v.shouldShowChildren");
        c.set("v.shouldShowChildren", !currentState);
    },
    toggleExcluded : function(c, e, h) {
        const currentState = c.get("v.shouldShowExcludedFields");
        c.set("v.shouldShowExcludedFields", !currentState);
    },
    toggleIncluded : function(c, e, h) {
        const currentState = c.get("v.shouldShowIncludedFields");
        c.set("v.shouldShowIncludedFields", !currentState);
    },
})