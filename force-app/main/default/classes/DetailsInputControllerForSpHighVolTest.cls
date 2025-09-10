@IsTest
private class DetailsInputControllerForSpHighVolTest {


    @IsTest
    private static void getSpHighVoltageScreenInfoTest_66kv_1() {
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String searchOption = '屋内';
        String searchOption2 = '66kV';
        String searchOption3 = '20/25kA';
        String searchOption4 = '800A';
        String searchOption5 = 'SF6ガス';
        String inputsRecords = null;

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo(true, device.Id, searchOption, searchOption2, searchOption3, searchOption4, searchOption5, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes); 

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //表
        Map<String, Object> setUnitPriceTable = (Map<String, Object>)res.get('setUnitPriceTable');
        if(setUnitPriceTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '66kV C-GISユニット単価';//66kVのデフォルト値
            String secTitle_actual = (String)setUnitPriceTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)setUnitPriceTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'No'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)setUnitPriceTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            

            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> '1'}, //No
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> 'DSユニット'}, //品名
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'}, 
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}//入力セル
                    }
                }
                ,new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> '1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'筐体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            }; 

            List<Object> bodyList_actualList = (List<Object>)setUnitPriceTable.get('bodyList');
            for(Integer i=0; i<bodyList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                    Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                    if(actaul.get('value') instanceof Map<string,object>) {
                        Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                        Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                        Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));
                        Assert.areEqual(expect.get('isRight'), actaul.get('isRight'));
                        Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));

                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                        Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                        Assert.areEqual(expect_value.get('Quantity'), actaul_value.get('Quantity'));
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_ExtraHighVoltage66Kv.split('\r\n'); 
            List<Object> noteList_actual = (List<Object>)setUnitPriceTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
    }

    @IsTest
    private static void getSpHighVoltageScreenInfoTest_66kv_2() {
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1_77kv' LIMIT 1];
        String searchOption = '屋内';
        String searchOption2 = '77kV';
        String searchOption3 = '20/25kA';
        String searchOption4 = '800A';
        String searchOption5 = 'SF6ガス';
        String inputsRecords = null;

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo(true, device.Id, searchOption, searchOption2, searchOption3, searchOption4, searchOption5, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes); 

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //表
        Map<String, Object> setUnitPriceTable = (Map<String, Object>)res.get('setUnitPriceTable');
        if(setUnitPriceTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '66kV C-GISユニット単価';//66kVのデフォルト値
            String secTitle_actual = (String)setUnitPriceTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)setUnitPriceTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'No'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)setUnitPriceTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            

            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> '1'}, //No
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> 'DSユニット'}, //品名
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'}, 
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}//入力セル
                    }
                }
                ,new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> '1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'筐体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            }; 

            List<Object> bodyList_actualList = (List<Object>)setUnitPriceTable.get('bodyList');
            for(Integer i=0; i<bodyList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                    Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                    if(actaul.get('value') instanceof Map<string,object>) {
                        Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                        Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                        Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));
                        Assert.areEqual(expect.get('isRight'), actaul.get('isRight'));
                        Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));

                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                        Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                        Assert.areEqual(expect_value.get('Quantity'), actaul_value.get('Quantity'));
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_ExtraHighVoltage66Kv.split('\r\n'); 
            List<Object> noteList_actual = (List<Object>)setUnitPriceTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
    }

    @IsTest
    private static void getSpHighVoltageScreenInfoTest_66kv_3() {
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1_110kv' LIMIT 1];
        String searchOption = '屋内';
        String searchOption2 = '110kV';
        String searchOption3 = '20/25kA';
        String searchOption4 = '800A';
        String searchOption5 = 'SF6ガス';
        String inputsRecords = null;

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo(true, device.Id, searchOption, searchOption2, searchOption3, searchOption4, searchOption5, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes); 

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //表
        Map<String, Object> setUnitPriceTable = (Map<String, Object>)res.get('setUnitPriceTable');
        if(setUnitPriceTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '66kV C-GISユニット単価';//66kVのデフォルト値
            String secTitle_actual = (String)setUnitPriceTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)setUnitPriceTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'No'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)setUnitPriceTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            

            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> '1'}, //No
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> 'DSユニット'}, //品名
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'}, 
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}//入力セル
                    }
                }
                ,new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=> '1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'筐体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            }; 

            List<Object> bodyList_actualList = (List<Object>)setUnitPriceTable.get('bodyList');
            for(Integer i=0; i<bodyList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                    Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                    if(actaul.get('value') instanceof Map<string,object>) {
                        Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                        Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                        Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));
                        Assert.areEqual(expect.get('isRight'), actaul.get('isRight'));
                        Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));

                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                        Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                        Assert.areEqual(expect_value.get('Quantity'), actaul_value.get('Quantity'));
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_ExtraHighVoltage66Kv.split('\r\n'); 
            List<Object> noteList_actual = (List<Object>)setUnitPriceTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
    }

    @IsTest
    private static void getSpHighVoltageScreenInfoTest_22kV_1() {
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1_2' LIMIT 1];
        String searchOption = '屋内';
        String searchOption2 = '22kV';
        String searchOption3 = '20/25kA'; 
        String searchOption4 = '800A';
        String searchOption5 = 'SF6ガス';
        String inputsRecords = null;

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo(true, device.Id, searchOption, searchOption2, searchOption3, searchOption4, searchOption5, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes); 

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //表
        Map<String, Object> setUnitPriceTable = (Map<String, Object>)res.get('setUnitPriceTable');
        if(setUnitPriceTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '22kV C-GISユニット単価';
            String secTitle_actual = (String)setUnitPriceTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)setUnitPriceTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'No'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)setUnitPriceTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'DSユニット'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
                ,new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'筐体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            }; 

            List<Object> bodyList_actualList = (List<Object>)setUnitPriceTable.get('bodyList');
            for(Integer i=0; i<bodyList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                    Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                    if(actaul.get('value') instanceof Map<string,object>) {
                        Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                        Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                        Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));
                        Assert.areEqual(expect.get('isRight'), actaul.get('isRight'));
                        Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));

                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                        Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                        Assert.areEqual(expect_value.get('Quantity'), actaul_value.get('Quantity'));
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_ExtraHighVoltage22Kv.split('\r\n');
            List<Object> noteList_actual = (List<Object>)setUnitPriceTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);

             //Check [noteList2]
            List<String> noteList2_expect = System.Label.Notice_ExtraHighVoltage22Kv.split('\r\n');
            List<Object> noteList2_actual = (List<Object>)setUnitPriceTable.get('noteList2');
            Assert.areEqual(noteList2_expect, noteList2_actual);

            
        }
    }

    @IsTest
    private static void getSpHighVoltageScreenInfoTest_22kV_2() {
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1_2' LIMIT 1];
        String searchOption = '屋内';
        String searchOption2 = '66kV';
        String searchOption3 = '20/25kA'; 
        String searchOption4 = '800A';
        String searchOption5 = 'SF6ガス';
        String inputsRecords = null;

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo(true, device.Id, searchOption, searchOption2, searchOption3, searchOption4, searchOption5, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes); 

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //表
        Map<String, Object> setUnitPriceTable = (Map<String, Object>)res.get('setUnitPriceTable');
        if(setUnitPriceTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '22kV C-GISユニット単価';
            String secTitle_actual = (String)setUnitPriceTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)setUnitPriceTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'No'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)setUnitPriceTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'DSユニット'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
                ,new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'筐体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            }; 

            List<Object> bodyList_actualList = (List<Object>)setUnitPriceTable.get('bodyList');
            for(Integer i=0; i<bodyList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                    Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                    if(actaul.get('value') instanceof Map<string,object>) {
                        Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                        Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                        Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));
                        Assert.areEqual(expect.get('isRight'), actaul.get('isRight'));
                        Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));

                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                        Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                        Assert.areEqual(expect_value.get('Quantity'), actaul_value.get('Quantity'));
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_ExtraHighVoltage22Kv.split('\r\n');
            List<Object> noteList_actual = (List<Object>)setUnitPriceTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);

             //Check [noteList2]
            List<String> noteList2_expect = System.Label.Notice_ExtraHighVoltage22Kv.split('\r\n');
            List<Object> noteList2_actual = (List<Object>)setUnitPriceTable.get('noteList2');
            Assert.areEqual(noteList2_expect, noteList2_actual);

            
        }
    }

    @IsTest
    private static void getSpHighVoltageScreenInfoTest_Cubicle() {
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1_3' LIMIT 1];
        String searchOption = '屋内';
        String searchOption2 = '22kV';
        String searchOption3 = '20/25kA'; 
        String searchOption4 = '800A';
        String searchOption5 = 'SF6ガス';
        String inputsRecords = null;

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo(true, device.Id, searchOption, searchOption2, searchOption3, searchOption4, searchOption5, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes); 

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //表
        Map<String, Object> setUnitPriceTable = (Map<String, Object>)res.get('setUnitPriceTable');
        if(setUnitPriceTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'ブロック(気中)キュービクル';
            String secTitle_actual = (String)setUnitPriceTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)setUnitPriceTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'No'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)setUnitPriceTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'VD'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
                ,new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'筐体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            }; 

            List<Object> bodyList_actualList = (List<Object>)setUnitPriceTable.get('bodyList');
            for(Integer i=0; i<bodyList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                    Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                    if(actaul.get('value') instanceof Map<string,object>) {
                        Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                        Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                        Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));
                        Assert.areEqual(expect.get('isRight'), actaul.get('isRight'));
                        Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));

                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                        Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                        Assert.areEqual(expect_value.get('Quantity'), actaul_value.get('Quantity'));
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_ExtraHighVoltageCubicle.split('\r\n');
            List<Object> noteList_actual = (List<Object>)setUnitPriceTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);

             //Check [noteList2]
            List<String> noteList2_expect = System.Label.Notice_ExtraHighVoltageCubicle.split('\r\n');
            List<Object> noteList2_actual = (List<Object>)setUnitPriceTable.get('noteList2');
            Assert.areEqual(noteList2_expect, noteList2_actual);

            
        }
    }

    //Detail
    @IsTest
    private static void submitSpHighVoltageDetailsTest() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE CategoryName__c='筐体' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1]; 
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        String res_actaul = DetailsInputControllerForSpHighVoltage.submitSpHighVoltageDetails(details, device.Id);
        Test.stopTest();

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        String res_expect = device.Quote__c;
        Assert.areEqual(res_expect, res_actaul);

        Detail__c detail_actual = [SELECT Id
                                    ,Device__c
                                    ,Name
                                    ,Name1__c
                                    ,Name2__c
                                    ,Name3__c
                                    ,Name4__c
                                    ,Name5__c
                                    ,DetailCategory__c
                                    ,WcCalculationRate__c
                                    ,RECNO__c
                                    ,MajorClassificationName__c
                                    ,MajorClassificationCode__c
                                    ,MinorClassificationName__c
                                    ,MinorClassificationCode__c
                                    ,CategoryCode__c
                                    ,PricingTableUniqueKey__c
                                    ,CreditWC__c
                                    ,Note__c
                                    ,UnitPrice__c
                                    ,UnitPriceCoefficient__c
                                    ,Quantity__c
                                    ,CreditWeight__c
                                    ,detailedStatementText__c
                                    ,SpecialSpecificationNo__c
                                    FROM Detail__c
                                    WHERE Device__r.Name='Test Device Name 1' AND Name = 'Test Detail Name 2'
                                    LIMIT 1];

        // Test data when input data testing
        Assert.areEqual(device.Id, detail_actual.Device__c);
        Assert.areEqual('Test Detail Name 2', detail_actual.Name);
        Assert.areEqual('屋内', detail_actual.Name1__c);
        Assert.areEqual('定格電流800A', detail_actual.Name4__c);
        Assert.areEqual('明細', detail_actual.DetailCategory__c);
        Assert.areEqual(0, detail_actual.WcCalculationRate__c);
        Assert.areEqual('特高', detail_actual.MajorClassificationName__c);
        Assert.areEqual('21', detail_actual.MajorClassificationCode__c);
        Assert.areEqual('66kV C-GIS', detail_actual.MinorClassificationName__c);
        Assert.areEqual('01', detail_actual.MinorClassificationCode__c);
        Assert.areEqual(null, detail_actual.CategoryCode__c);
        Assert.areEqual('屋内 筐体', detail_actual.PricingTableUniqueKey__c);
        Assert.areEqual(0, detail_actual.CreditWC__c);
        Assert.areEqual('Test Detail Note', detail_actual.Note__c);
        Assert.areEqual(0, detail_actual.UnitPrice__c);
        Assert.areEqual(0, detail_actual.UnitPriceCoefficient__c);
        Assert.areEqual(1, detail_actual.Quantity__c);
        Assert.areEqual(0, detail_actual.CreditWeight__c);
        Assert.areEqual('Test Detail Statement', detail_actual.detailedStatementText__c);
        Assert.areEqual(0, detail_actual.SpecialSpecificationNo__c);
    }

    //Error
    @IsTest
    private static void submitSpHighVoltageDetailsErrorTest() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE CategoryName__c='明細' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        String res_actaul = DetailsInputControllerForSpHighVoltage.submitSpHighVoltageDetails(details, 'error');
        Test.stopTest();

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        String res_expect = 'Error';
        Assert.areEqual(res_expect, res_actaul);
    }

    @IsTest
    private static void getSpHighVoltageScreenInfoInputDataTest() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='屋内' LIMIT 1];

        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String searchOption = '屋内';
        String searchOption2 = '66kV';
        String searchOption3 = '20/25kA';
        String searchOption4 = '800A';
        String searchOption5 = 'SF6ガス';
        String inputsRecords = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForSpHighVoltage.getSpHighVoltageScreenInfo(true, device.Id, searchOption, searchOption2, searchOption3, searchOption4, searchOption5, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // 66kV C-GISユニット単価
        Map<String, Object> setUnitPriceTable = (Map<String, Object>)res.get('setUnitPriceTable');
        if(setUnitPriceTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '66kV C-GISユニット単価';
            String secTitle_actual = (String)setUnitPriceTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)setUnitPriceTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'No'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)setUnitPriceTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'DSユニット'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>1}}
                    }
                }
                ,new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'筐体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>1}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)setUnitPriceTable.get('bodyList');
            for(Integer i=0; i<bodyList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)bodyList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)bodyList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Map<String, Object> expect = (Map<String, Object>)cellList_expect.get(j);
                    Map<String, Object> actaul = (Map<String, Object>)cellList_actaul.get(j);

                    if(actaul.get('value') instanceof Map<string,object>) {
                        Assert.areEqual(expect.get('colSpanCnt'), actaul.get('colSpanCnt'));
                        Assert.areEqual(expect.get('isColSpan'), actaul.get('isColSpan'));
                        Assert.areEqual(expect.get('isEdit'), actaul.get('isEdit'));
                        Assert.areEqual(expect.get('isRight'), actaul.get('isRight'));
                        Assert.areEqual(expect.get('isRowSpan'), actaul.get('isRowSpan'));
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));

                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                        Assert.areEqual(expect_value.get('Price'), actaul_value.get('Price'));
                        Assert.areEqual(expect_value.get('Quantity'), actaul_value.get('Quantity'));
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_ExtraHighVoltage66Kv.split('\r\n'); 
            List<Object> noteList_actual = (List<Object>)setUnitPriceTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
    }

    @TestSetup
    static void createTestData(){
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        //                                    PricingTable__c                                       //
        //////////////////////////////////////////////////////////////////////////////////////////////
        
        //明細用
        //Integer recNo = 0;
        List<String> detailName1_list = new List<String>{
            '屋内',
            '屋外'
        };

        //筐体用
        Integer recNo = 0;
        List<String> chassisName1_list = new List<String>{ 
            '屋内',
            '屋外'
        };
        List<String> chassisName2_list = new List<String>{ 
            'SF6ガス',
            'ドライエア'
        };
        List<String> chassisName3_list = new List<String>{ 
            '定格電圧66kV',
            '定格電圧77kV',
            '定格電圧110kV'
        };
        List<String> chassisName4_list = new List<String>{
            '定格電流800A',
            '定格電流1200A(1250A)'
        };
        List<String> chassisName5_list = new List<String>{
            '定格遮断電流20/25kA',
            '定格遮断電流31.5kA'
        };

        //名称1 品名
        List<String> nameList = new List<String>{
            'DSユニット',
            'VCB・GCBユニット',
            'ESユニット',
            'GPTユニット',
            'LAユニット',
            '①VCT・MOFユニット',
            '②VCT・MOFユニット',
            'VDユニット',
            '①受電側CTユニット(ケーブル接続)',
            '②受電側CTユニット(架空線接続)',
            '変圧器側CTユニット'
        };

        //表示用テキスト 66kV 筐体
        List<String> categoryNameList1 = new List<String>{
            'DSユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            'VCB・GCBユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            'ESユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            'GPTユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            'LAユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            '①VCT・MOFユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            '②VCT・MOFユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            'VDユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            '①受電側CTユニット(ケーブル接続) SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            '②受電側CTユニット(架空線接続) SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            '変圧器側CTユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA'
        };

        //66kV
        RecordType chassisRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Chassis' AND SobjectType='PricingTable__c' LIMIT 1];
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
            for(String name1 : categoryNameList1){
                for(String name2 : chassisName2_list) {
                    for(String name3 : chassisName3_list) {
                        for(String name4 : chassisName4_list) {
                            for(String name5 : chassisName5_list){
                                pricingTableList.add(new PricingTable__c(
                                    RecordTypeId=chassisRecordType.Id,
                                    BU__c='S',
                                    RECNo__c=++recNo,
                                    MajorClassificationName__c='特高',
                                    MinorClassificationName__c='66kV C-GIS',
                                    CategoryName__c='筐体',//種類名
                                    DisplayName__c=name1, //表示用テキスト
                                    Name1__c= '屋内',
                                    Name2__c=name2,
                                    Name3__c=name3,
                                    Name4__c=name4,
                                    Name5__c=name5,
                                    WC__c=null,
                                    Price__c=999999,
                                    Note__c=''
                                ));
                            }
                        }
                    }
                }
            }
        
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=chassisRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='特高',
            MinorClassificationName__c='66kV C-GIS',
            CategoryName__c='筐体',//種類名
            DisplayName__c='DSユニット', //表示用テキスト
            Name1__c= 'DSユニット',
            Name2__c='SF6ガス',
            Name3__c='定格電圧66kV',
            Name4__c='定格電流800A',
            Name5__c='定格遮断電流20/25kA',
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        

        RecordType detailRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='detail' AND SobjectType='PricingTable__c' LIMIT 1];
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='M',
            RECNo__c=++recNo,
            MajorClassificationName__c='特高',
            MinorClassificationName__c='66kV C-GIS',
            CategoryName__c='明細',//種類名
            DisplayName__c='屋内 筐体', //表示用テキスト
            Name1__c='屋内',
            Name2__c='筐体',
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));

        //22kV
        //筐体用
        List<String> chassisName1_list_2 = new List<String>{ 
            '屋内',
            '屋外'
        };
        List<String> chassisName3_list_2 = new List<String>{ 
            '定格電圧22kV',
            '定格電圧33kV'
        };
        List<String> chassisName4_list_2 = new List<String>{
            '定格電流800A',
            '定格電流1200A(1250A)'
        };

        //表示用テキスト 22kV 
        List<String> categoryNameList2 = new List<String>{
            'DSユニット SF6ガス 定格電圧22kV 定格電流800A',
            'VCB・GCBユニット SF6ガス 定格電圧22kV 定格電流800A',
            'ESユニット SF6ガス 定格電圧22kV 定格電流800A',
            'GPTユニット SF6ガス 定格電圧22kV 定格電流800A',
            'LAユニット SF6ガス 定格電圧22kV 定格電流800A',
            'VCT・MOFユニット SF6ガス 定格電圧22kV 定格電流800A',
            'VDユニット SF6ガス 定格電圧22kV 定格電流800A',
            'CTユニット SF6ガス 定格電圧22kV 定格電流800A'
        };

        //表示用テキスト ブロック(気中)キュービクル
        List<String> categoryNameList3 = new List<String>{
            'VD 定格電圧22kV 定格電流800A',
            'VCB 定格電圧22kV 定格電流800A',
            'DS 定格電圧22kV 定格電流800A',
            'LBS 定格電圧22kV 定格電流800A',
            'CT 定格電圧22kV 定格電流800A',
            'PT 定格電圧22kV 定格電流800A',
            'GPT 定格電圧22kV 定格電流800A',
            'LA 定格電圧22kV 定格電流800A'
        };

        //22kV
        RecordType chassisRecordType2 = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Chassis' AND SobjectType='PricingTable__c' LIMIT 1];
            for(String name1 : categoryNameList1){
                for(String name3 : chassisName3_list) {
                    for(String name4 : chassisName4_list) {
                        pricingTableList.add(new PricingTable__c(
                            RecordTypeId=chassisRecordType2.Id,
                            BU__c='S',
                            RECNo__c=++recNo,
                            MajorClassificationName__c='特高',
                            MinorClassificationName__c='22kV C-GIS',
                            CategoryName__c='筐体',//種類名
                            DisplayName__c=name1, //表示用テキスト
                            Name1__c= '屋内',
                            Name3__c=name3,
                            Name4__c=name4,
                            WC__c=null,
                            Price__c=999999,
                            Note__c=''
                        ));
                    }
                }
            }

        RecordType detailRecordType2 = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='detail' AND SobjectType='PricingTable__c' LIMIT 1];
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType2.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='特高',
            MinorClassificationName__c='22kV C-GIS',
            CategoryName__c='明細',//種類名
            DisplayName__c='屋内 筐体', //表示用テキスト
            Name1__c='屋内',
            Name2__c='筐体',
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));

        //ブロック(気中)キュービクル
        RecordType chassisRecordType3 = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Chassis' AND SobjectType='PricingTable__c' LIMIT 1];
            for(String name1 : categoryNameList1){
                for(String name3 : chassisName3_list) {
                    for(String name4 : chassisName4_list) {
                        pricingTableList.add(new PricingTable__c(
                            RecordTypeId=chassisRecordType3.Id,
                            BU__c='S',
                            RECNo__c=++recNo,
                            MajorClassificationName__c='特高',
                            MinorClassificationName__c='ブロック(気中)キュービクル',
                            CategoryName__c='筐体',//種類名
                            DisplayName__c=name1, //表示用テキスト
                            Name1__c= '屋内',
                            Name3__c=name3,
                            Name4__c=name4,
                            WC__c=null,
                            Price__c=999999,
                            Note__c=''
                        ));
                    }
                }
            }

        RecordType detailRecordType3 = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='detail' AND SobjectType='PricingTable__c' LIMIT 1];
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType3.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='特高',
            MinorClassificationName__c='ブロック(気中)キュービクル',
            CategoryName__c='明細',//種類名
            DisplayName__c='屋内 筐体', //表示用テキスト
            Name1__c='屋内',
            Name2__c='筐体',
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        
        insert pricingTableList;
        //////////////////////////////////////////////////////////////////////////////////////////////
        //                    Account, Quote__c, Device__c, Detail__c                               // 
        //////////////////////////////////////////////////////////////////////////////////////////////

        //Account
        Account account = new Account(
            Name='Test Account Name'
        );
        insert account;

        //Quote
        // 施設
        RecordType quoteFacilityRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote1 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 1',
            QuoteNumber__c='1234567890',
            GeneralAdministrativeExpenses__c='23',
            PowerFrequency__c='50Hz',
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteFacilityRecordType.Id
        );
        //insert quote1;

        // 施設
        RecordType quoteFacilityRecordType1_2 = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote1_2 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 1',
            QuoteNumber__c='2234567890',
            GeneralAdministrativeExpenses__c='23',
            PowerFrequency__c='50Hz',
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteFacilityRecordType1_2.Id
        );
        //insert quote1_2;

        // 施設
        RecordType quoteFacilityRecordType1_3 = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote1_3 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 1',
            QuoteNumber__c='3234567890',
            GeneralAdministrativeExpenses__c='23',
            PowerFrequency__c='50Hz',
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteFacilityRecordType1_3.Id
        );
        //insert quote1_3;

        // 水環境
        RecordType quoteWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote2 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 2',
            QuoteNumber__c='1234567891',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz',
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteWaterRecordType.Id
        );
        //insert quote2;

        // 官需
        RecordType quotePDemandRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='官需' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote3 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 3',
            QuoteNumber__c='1234567893',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz',
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quotePDemandRecordType.Id
        );
        //insert quote3;


        List<Quote__c> quoteList = new List<Quote__c>();
        quoteList.add(quote1);
        quoteList.add(quote1_2);
        quoteList.add(quote1_3);
        quoteList.add(quote2);
        quoteList.add(quote3);
        insert quoteList;

        //Device
        //施設　
        //66kV 定格電圧66kV
        RecordType deviceFacilityRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Device__c' LIMIT 1];
        Device__c device1 = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='',
            QuoteSpecificationNumber__c='1234567890',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c='特高',
            MinorClassification__c='66kV C-GIS',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        //insert device1;

        Device__c device_66kV = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1_66kV',
            Note__c='Test Device Note',
            Quantity__c='0',
            Unit__c='',
            QuoteSpecificationNumber__c='3234567892',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c='特高',
            MinorClassification__c='66kV C-GIS',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        //insert device_66kV;

        //66kV 定格電圧77kV
        Device__c device1_77kv = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1_77kv',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='',
            QuoteSpecificationNumber__c='1234567802',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c='特高',
            MinorClassification__c='66kV C-GIS',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        //insert device1_77kv;

        //66kV 定格電圧110kV
        Device__c device1_110kv = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1_110kv',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='',
            QuoteSpecificationNumber__c='1234567803',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c='特高',
            MinorClassification__c='66kV C-GIS',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        //insert device1_110kv;
        
        //22kV
        Device__c device1_2 = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1_2',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='',
            QuoteSpecificationNumber__c='2234567890',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c='特高',
            MinorClassification__c='22kV C-GIS',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        //insert device1_2;

        //ブロックキュービクル
        Device__c device1_3 = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1_3',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='',
            QuoteSpecificationNumber__c='3234567890',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c='特高',
            MinorClassification__c='ブロック(気中)キュービクル',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        //insert device1_3;

        // 水環境
        RecordType deviceWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Device__c' LIMIT 1];
        Device__c device2 = new Device__c(
            Quote__c=quote2.Id,
            Name='Test Device Name 2',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='',
            QuoteSpecificationNumber__c='1234567891',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='水環境',
            MajorClassification__c='特高',
            MinorClassification__c='66kV C-GIS',
            ClientAnswerWeight_free__c=0, //客先回答重量
            CreditWeight__c=0, //客先回答金額
            PriceCoefficient__c=0, //単位重量
            DisplayOrder__c=1, //表示順
            EquipManageCostTarget__c=false, //true
            GeneralAdminExpensesExistence__c=false, //true
            RecordTypeId=deviceWaterRecordType.Id
        );
        //insert device2;
        

        //官需
        RecordType devicePDemandRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='官需' AND SobjectType='Device__c' LIMIT 1];
        Device__c device3 = new Device__c(
            Quote__c=quote3.Id,
            Name='Test Device Name 3',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='',
            QuoteSpecificationNumber__c='1234567893',
            NETCalculateCategory__c='', 
            RecordTypeOfQuote__c='官需',
            MajorClassification__c='特高',
            MinorClassification__c='66kV C-GIS',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=devicePDemandRecordType.Id
        );
        //insert device3;


        List<Device__c> deviceList = new List<Device__c>();
        deviceList.add(device1);
        deviceList.add(device_66kV);
        deviceList.add(device1_77kv);
        deviceList.add(device1_110kv);
        deviceList.add(device1_2);
        deviceList.add(device1_3);
        deviceList.add(device2);
        deviceList.add(device3);
        insert deviceList;


        //既存
        //Detail
        List<Detail__c> details = new List<Detail__c>();
        List<Detail__c> details1 = new List<Detail__c>();
        List<Detail__c> details1_2 = new List<Detail__c>();
        List<Detail__c> details1_3 = new List<Detail__c>();
        List<Detail__c> details2 = new List<Detail__c>();
        List<Detail__c> details3 = new List<Detail__c>();
        // 66kV　筐体　定格電圧66kV
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Chassis Name 1',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name2__c='SF6ガス',
            Name3__c='定格電圧66kV',
            Name4__c='定格電流800A',
            Name5__c='定格遮断電流20/25kA',
            Name10__c= null,
            PricingTableUniqueKey__c='筐体S特高66kV C-GIS筐体DSユニットSF6ガス定格電圧66kV定格電流800A定格遮断電流20/25kA',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        details1.add(new Detail__c(
            Device__c=device_66kV.Id,
            PricingTable__c=null,
            Name='Test Device Name 1_66kV',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name2__c='SF6ガス',
            Name3__c='定格電圧66kV',
            Name4__c='定格電流800A',
            Name5__c='定格遮断電流20/25kA',
            Name10__c= null,
            PricingTableUniqueKey__c='DSユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=0,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Chassis Name 1_66kV',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name2__c='SF6ガス',
            Name3__c='定格電圧66kV',
            Name4__c='定格電流800A',
            Name5__c='定格遮断電流20/25kA',
            Name10__c= null,
            PricingTableUniqueKey__c='DSユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=0,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));
        //  明細
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Detail Name 2',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='明細',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name4__c='定格電流800A',
            Name10__c= null,
            PricingTableUniqueKey__c='屋内 筐体',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        // 66kV　筐体　定格電圧77kV
        details1_2.add(new Detail__c(
            Device__c=device1_77kv.Id,
            PricingTable__c=null,
            Name='Test Chassis Name 1_77kV',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name2__c='SF6ガス',
            Name3__c='定格電圧77kV',
            Name4__c='定格電流800A',
            Name5__c='定格遮断電流20/25kA',
            Name10__c= null,
            PricingTableUniqueKey__c='DSユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));
        //  明細
        details1_2.add(new Detail__c(
            Device__c=device1_110kv.Id,
            PricingTable__c=null,
            Name='Test Detail Name 2_77kV',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='明細',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name4__c='定格電流800A',
            Name10__c= null,
            PricingTableUniqueKey__c='屋内 筐体',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        // 66kV　筐体　定格電圧110kV
        details1_3.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Chassis Name 1_110kV',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name2__c='SF6ガス',
            Name3__c='定格電圧110kV',
            Name4__c='定格電流800A',
            Name5__c='定格遮断電流20/25kA',
            Name10__c= null,
            PricingTableUniqueKey__c='DSユニット SF6ガス 定格電圧66kV 定格電流800A 定格遮断電流20/25kA',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));
        //  明細
        details1_3.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Detail Name 2_110kV',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='66kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='明細',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name4__c='定格電流800A',
            Name10__c= null,
            PricingTableUniqueKey__c='屋内 筐体',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        // 22kV 筐体
        details2.add(new Detail__c(
            Device__c=device1_2.Id,
            PricingTable__c=null,
            Name='Test Chassis Name 1_2',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='02',
            MinorClassificationName__c='22kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name3__c='定格電圧22kV',
            Name4__c='定格電流800A',
            Name10__c= null,
            PricingTableUniqueKey__c='DSユニット SF6ガス 定格電圧22kV 定格電流800A',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=0,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=1,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));
        //  明細
        details2.add(new Detail__c(
            Device__c=device1_2.Id,
            PricingTable__c=null,
            Name='Test Detail Name 2_2',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='02',
            MinorClassificationName__c='22kV C-GIS',
            CategoryCode__c='',
            CategoryName__c='明細',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name2__c='筐体',
            PricingTableUniqueKey__c='屋内 筐体',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=0,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=1,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        // ブロック(気中)キュービクル 筐体
        details3.add(new Detail__c(
            Device__c=device1_3.Id,
            PricingTable__c=null,
            Name='Test Chassis Name 1_3',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='03',
            MinorClassificationName__c='ブロック(気中)キュービクル',
            CategoryCode__c='',
            CategoryName__c='筐体',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name3__c='定格電圧22kV',
            Name4__c='定格電流800A',
            Name10__c= null,
            PricingTableUniqueKey__c='VD 定格電圧22kV 定格電流800A',
            Order__c='Test Order',
            DetailCategory__c='筐体', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=1,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));
        //  明細
        details3.add(new Detail__c(
            Device__c=device1_3.Id,
            PricingTable__c=null,
            Name='Test Detail Name 2_3',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='03',
            MinorClassificationName__c='ブロック(気中)キュービクル',
            CategoryCode__c='',
            CategoryName__c='明細',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='屋内',
            Name2__c='筐体',
            PricingTableUniqueKey__c='屋内 筐体',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=1,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));
        insert details;
        insert details1;
        insert details1_2;
        insert details1_3;
        insert details2;
        insert details3;
    }
}