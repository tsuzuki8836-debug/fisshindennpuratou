({
	afterRender: function (cmp, helper) {
		this.superAfterRender();
		var recordList = cmp.get('v.recordList');
        const isHaveNoError = cmp.get("v.isHaveNoError");
        let condition = cmp.get('v.conditionsFilterList');
        cmp.set('v.originCondition',condition);
		if(recordList.length > 0 && isHaveNoError){
            helper.getColumnDefinitions(cmp, recordList);
            helper.getObjectLabel(cmp);
        	helper.getRelationshipName(cmp);
            helper.getTabStyle(cmp);
		} else {
            var defaultObjectLabel = cmp.get("v.defaultLabel");
            if (defaultObjectLabel !== "") {
                cmp.set("v.title",  defaultObjectLabel);
            }
        }
	}
})