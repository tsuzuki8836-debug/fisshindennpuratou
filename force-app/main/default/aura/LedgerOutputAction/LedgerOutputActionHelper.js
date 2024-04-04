({
    ledgertOutput : function(component) {
		let action = component.get("c.LedgerSheetOutput");

		action.setParams({
			"recordId" : component.get("v.recordId")
		});

		action.setCallback(this, function(response) {
			let state = response.getState();
			console.log(state);
			if (state === "SUCCESS") {
				component.set("v.message", "帳票書類の出力が終了しました。");
				component.set("v.url", response.getReturnValue());
				// console.log(response.getReturnValue());
				// console.log(component.get("v.url"));
                $A.get('e.force:refreshView').fire();
				// window.open(component.get("v.url"));
				component.set("v.isVisible", true);
			} else if (state === "ERROR") {
				let errors = response.getError();
				console.log(errors);
				if (errors) {
					if (errors[0] && errors[0].message) {
						component.set("v.message", "出力エラーが発生しました。管理者に連絡してください。" + "/n" + errors[0].message);
						component.set("v.isVisible", true);
					}
				} else {
					component.set("v.message", "予期しないエラーが発生しました。");
					component.set("v.isVisible", true);
				}
			}
		});

		$A.enqueueAction(action);
	}
})