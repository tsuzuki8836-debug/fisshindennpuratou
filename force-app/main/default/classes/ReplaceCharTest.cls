@isTest
private class ReplaceCharTest {

    @isTest
    private static void convertFullToHalfTest001(){
        String value = '';

        //テスト実行
        Test.startTest();

        String result = ReplaceChar.convertFullToHalf(value);

        Test.stopTest();

        Assert.areEqual('', result);
    }

    @isTest
    private static void convertFullToHalfTest002(){
        String value = 'あいう１２３，？';

        //テスト実行
        Test.startTest();

        String result = ReplaceChar.convertFullToHalf(value);

        Test.stopTest();

        Assert.areEqual('あいう123？', result);
    }

    @isTest
    private static void convertHalfToFullForFileNameTest001(){
        String value = '\\-/-:-*-?-"-<->-|';

        //テスト実行
        Test.startTest();

        String result = ReplaceChar.convertHalfToFullForFileName(value);

        Test.stopTest();

        Assert.areEqual('￥-／-：-＊-？-”-＜-＞-｜', result);
    }
}