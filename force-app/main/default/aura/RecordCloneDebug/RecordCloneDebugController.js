({
    doInit : function(c, e, h) {
        h.callAction(c, 'c.showAllChildRelationships', {
            recordId : c.get('v.recordId'),
            objectName : c.get('v.targetSObject')
        })
        .then(function(summary) {
            if(!summary) {
                c.set('v.isInvalidObjectName', true);
                return;
            }
            console.log(summary);
            const childrenList = [];
            const childrenListStr = [];
            c.set('v.objectName', summary.objectName);
            for(let key of Object.keys(summary.relations)) {
                childrenList.push(key + ' : ' + summary.relations[key]);
                childrenListStr.push(key);
            }
            c.set('v.childrenList', childrenList);
            c.set('v.childrenListStr', childrenListStr.join(','));
        })
        .catch();
    },    
})