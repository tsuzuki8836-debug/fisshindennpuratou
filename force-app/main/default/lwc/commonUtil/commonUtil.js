/*
 * 空白チェック
 * that this をセットする
 * message メッセージ
 * val 空白、Null、undefined以外の場合 true
 */
const isNotEmpty = (val) =>{
    return (val!=null &&val!='' && val!=undefined);
}

//単価　＊ 係数 ＊　数量　＝　価格
const priceCalculator=(values) => {
    var coefficient = values['Coefficient__c'];
    //単価　＊　数量
    var price = parseFloat(values['UnitPrice__c']) * parseFloat(values['Quantity__c']);
    if (Number.isNaN(price)){
        price = '';
    }
    //係数がある場合
    //価格　＊　係数
    if (isNotEmpty(coefficient)) {
        price=parseInt(price) * parseFloat(coefficient);
        if (Number.isNaN(price)){
            price = '';
        }else{
            price =parseInt(price);
        }
    }
    return price;
}

//メソッドをexport する
export { isNotEmpty, priceCalculator };