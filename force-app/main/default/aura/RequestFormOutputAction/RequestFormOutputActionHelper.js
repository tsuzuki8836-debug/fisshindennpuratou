({
  callRequestFormOutput: function (component) {
    let action = component.get("c.requestFormOutput");

    action.setParams({
      recordId: component.get("v.recordId")
    });

    action.setCallback(this, function (response) {
      let state = response.getState();
      console.log(state);
      if (state === "SUCCESS") {
        component.set("v.message", "帳票書類の出力が終了しました。");
        $A.get("e.force:refreshView").fire();
        component.set("v.isVisible", true);
      } else if (state === "ERROR") {
        let errors = response.getError();
        console.log(errors);
        if (errors) {
          if (errors[0] && errors[0].message) {
            component.set("v.message", errors[0].message + "\r\n" + "システム管理者へ連絡してください。");
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
});