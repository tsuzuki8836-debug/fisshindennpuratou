@isTest
private class DetailsInputForControlCenterTest{

    @isTest
    private static void getControlCenterScreenInfoTest(){
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String inputsRecords = null;

        Test.startTest();
        String testRes = DetailsInputForControlCenterController.getControlCenterScreenInfo(device.Id, inputsRecords);
        Test.stopTest();
        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes);

        ////////////////////////////////////////////////
        //EMC総量
        Map<String,Object> EMCTable = (Map<String,Object>)res.get('EMCTable');
        if (EMCTable != null) {
            String secTitle_expect = 'EMC総量';
            String secTitle_actual = (String)EMCTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)EMCTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)EMCTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)EMCTable.get('bodyList');
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
                        //Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = new List<String>();
            List<Object> noteList_actual = (List<Object>)EMCTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////
        //外箱（盤）
        Map<String,Object> outerBoxTable = (Map<String,Object>)res.get('outerBoxtable');
        if (outerBoxTable != null) {
            String secTitle_expect = '外箱（盤）';
            String secTitle_actual = (String)outerBoxTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '（1面当り価格）';
            String comment_actual = (String)outerBoxTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>''},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)outerBoxTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)outerBoxTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_ControlCenter_OuterCase.split('\r\n');
            List<Object> noteList_actual = (List<Object>)outerBoxTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////
        //制御用電源用変圧器 （単相２線、400.200V/100V)
        Map<String,Object> controlPowerTransformerTable = (Map<String,Object>)res.get('controlPowerTransformerTable');
        if (controlPowerTransformerTable != null) {
            String secTitle_expect = '制御用電源用変圧器 （単相２線、400.200V/100V)';
            String secTitle_actual = (String)controlPowerTransformerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)controlPowerTransformerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'kVA'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)controlPowerTransformerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'制御用変圧器単体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'制御電源用ユニット'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)controlPowerTransformerTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_ControlCenter_ControlPowerSupply.split('\r\n');
            List<Object> noteList_actual = (List<Object>)controlPowerTransformerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////
        //引込盤 ・ 引込ユニット
        Map<String,Object> pullInTable = (Map<String,Object>)res.get('pullInTable');
        if (pullInTable != null) {
            String secTitle_expect = '引込盤 ・ 引込ユニット';
            String secTitle_actual = (String)pullInTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)pullInTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'図'},
                        new Map<String, Object>{'colSpanCnt'=>4, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'AF'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'引込盤'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'引込ユニット'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)pullInTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)pullInTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_ControlCenter_PullBoard.split('\r\n');
            List<Object> noteList_actual = (List<Object>)pullInTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //非可逆・可逆ユニット
        Map<String,Object> reversibleTable = (Map<String,Object>)res.get('reversibleTable');
        if (reversibleTable != null) {
            String secTitle_expect = '非可逆 ・ 可逆ユニット';
            String secTitle_actual = (String)reversibleTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)reversibleTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>4, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'200V'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'kW'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'非可逆ユニット'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'可逆ユニット'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)reversibleTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)reversibleTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_ControlCenter_Reversible.split('\r\n');
            List<Object> noteList_actual = (List<Object>)reversibleTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //スター・デルタユニット
        Map<String,Object> stardeltaTable = (Map<String,Object>)res.get('stardeltaTable');
        if (stardeltaTable != null) {
            String secTitle_expect = 'スター・デルタユニット';
            String secTitle_actual = (String)stardeltaTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)stardeltaTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Y-Δ'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Y-Δ(4コンダクタ)'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'kW'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'200V'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'200V'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)stardeltaTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)stardeltaTable.get('bodyList');
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
            List<String> noteList_expect = new List<String>();
            List<Object> noteList_actual = (List<Object>)stardeltaTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //電源送り（MCCB）ユニット
        Map<String,Object> MCCBTable = (Map<String,Object>)res.get('MCCBTable');
        if (MCCBTable != null) {
            String secTitle_expect = '電源送り（MCCB）ユニット';
            String secTitle_actual = (String)MCCBTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)MCCBTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'AF'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)MCCBTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)MCCBTable.get('bodyList');
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
                        //Assert.areEqual(expect, actaul);
                    }
                }
            }

            //Check [noteList]
            List<String> noteList_expect = new List<String>();
            List<Object> noteList_actual = (List<Object>)MCCBTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //指示計・保護継電器類
        Map<String,Object> indicatorTable = (Map<String,Object>)res.get('indicatorTable');
        if (indicatorTable != null) {
            String secTitle_expect = '指示計・保護継電器類';
            String secTitle_actual = (String)indicatorTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)indicatorTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>''},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)indicatorTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'displayname'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)indicatorTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_ControlCenter_Indicator.split('\r\n');
            List<Object> noteList_actual = (List<Object>)indicatorTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //リアクトル起動回路
        Map<String,Object> reactorTable = (Map<String,Object>)res.get('reactorTable');
        if (reactorTable != null) {
            String secTitle_expect = 'リアクトル起動回路';
            String secTitle_actual = (String)reactorTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)reactorTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'電動機容量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'200V'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)reactorTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)reactorTable.get('bodyList');
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
            List<String> noteList_expect = new List<String>();
            List<Object> noteList_actual = (List<Object>)reactorTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //Ｃ／Ｃ用 進相コンデンサ
        Map<String,Object> staticcondenserTable = (Map<String,Object>)res.get('staticcondenserTable');
        if (staticcondenserTable != null) {
            String secTitle_expect = 'Ｃ／Ｃ用 進相コンデンサ';
            String secTitle_actual = (String)staticcondenserTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)staticcondenserTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格出力'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'kW'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)staticcondenserTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'μF'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'50Hz'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'200V'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}

                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)staticcondenserTable.get('bodyList');
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
            List<String> noteList_expect = new List<String>();
            List<Object> noteList_actual = (List<Object>)staticcondenserTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //インバータ（ＶＶＶＦ装置・可変電圧可変周波数装置）
        Map<String,Object> inverterTable = (Map<String,Object>)res.get('inverterTable');
        if (inverterTable != null) {
            String secTitle_expect = 'インバータ（ＶＶＶＦ装置・可変電圧可変周波数装置）';
            String secTitle_actual = (String)inverterTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)inverterTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'容量(kW）'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'200V'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)inverterTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)inverterTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_ControlCenter_Inverter.split('\r\n');
            List<Object> noteList_actual = (List<Object>)inverterTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        ////////////////////////////////////////////////
        //高力率コンバータ付インバータ
        Map<String,Object> highinverterTable = (Map<String,Object>)res.get('highinverterTable');
        if (highinverterTable != null) {
            String secTitle_expect = '高力率コンバータ付インバータ';
            String secTitle_actual = (String)highinverterTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)highinverterTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'容量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'200V'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)highinverterTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)highinverterTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_ControlCenter_HighInverter.split('\r\n');
            List<Object> noteList_actual = (List<Object>)highinverterTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
    }

    //Detail
    @IsTest
    private static void submitControlCenterDetailsTest() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='TestDetail Name1' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';
        Integer cnt=0 ;

        Test.startTest();
        String res_actaul = DetailsInputForControlCenterController.submitControlCenterDetails(details, device.Id,cnt);
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
                                    WHERE Device__r.Name='Test Device Name 1' AND Name = 'Test Detail Name'
                                    LIMIT 1];

        // Test data when input data testing
        Assert.areEqual(device.Id, detail_actual.Device__c);
        Assert.areEqual('Test Detail Name', detail_actual.Name);
        Assert.areEqual('Test Detail Name 1', detail_actual.Name1__c);
        Assert.areEqual('Test Detail Name 2', detail_actual.Name2__c);
        Assert.areEqual('Test Detail Name 3', detail_actual.Name3__c);
        Assert.areEqual('Test Detail Name 4', detail_actual.Name4__c);
        Assert.areEqual('明細', detail_actual.DetailCategory__c);
        Assert.areEqual(0, detail_actual.WcCalculationRate__c);
        Assert.areEqual('コントロールセンタ(C/C)', detail_actual.MajorClassificationName__c);
        Assert.areEqual('27', detail_actual.MajorClassificationCode__c);
        Assert.areEqual('共通', detail_actual.MinorClassificationName__c);
        Assert.areEqual('00', detail_actual.MinorClassificationCode__c);
        Assert.areEqual(null, detail_actual.CategoryCode__c);
        Assert.areEqual('Test Unique Key', detail_actual.PricingTableUniqueKey__c);
        Assert.areEqual(0, detail_actual.CreditWC__c);
        Assert.areEqual('Test Detail Note', detail_actual.Note__c);
        Assert.areEqual(0, detail_actual.UnitPrice__c);
        Assert.areEqual(0, detail_actual.UnitPriceCoefficient__c);
        Assert.areEqual(1, detail_actual.Quantity__c);
        Assert.areEqual(0, detail_actual.CreditWeight__c);
        Assert.areEqual('Test Detail Statement', detail_actual.detailedStatementText__c);
        Assert.areEqual(99999, detail_actual.SpecialSpecificationNo__c);
    }

    @IsTest
    private static void submitControlCenterDetailsTest1() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='スター・デルタユニット' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';
        Integer cnt=0 ;
        if(price != null){
            cnt = 1;
        }

        Test.startTest();
        String res_actaul = DetailsInputForControlCenterController.submitControlCenterDetails(details, device.Id,cnt);
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
                                    WHERE Device__r.Name='Test Device Name 1' AND Name = 'TestDetail'
                                    LIMIT 1];

        // Test data when input data testing
        Assert.areEqual(device.Id, detail_actual.Device__c);
        Assert.areEqual('TestDetail', detail_actual.Name);
        Assert.areEqual('Test Detail Name 1', detail_actual.Name1__c);
        Assert.areEqual('Test Detail Name 2', detail_actual.Name2__c);
        Assert.areEqual('Test Detail Name 3', detail_actual.Name3__c);
        Assert.areEqual('Test Detail Name 4', detail_actual.Name4__c);
        Assert.areEqual('明細', detail_actual.DetailCategory__c);
        Assert.areEqual(0, detail_actual.WcCalculationRate__c);
        Assert.areEqual('コントロールセンタ(C/C)', detail_actual.MajorClassificationName__c);
        Assert.areEqual('27', detail_actual.MajorClassificationCode__c);
        Assert.areEqual('200V', detail_actual.MinorClassificationName__c);
        Assert.areEqual('01', detail_actual.MinorClassificationCode__c);
        Assert.areEqual(null, detail_actual.CategoryCode__c);
        Assert.areEqual('Test Unique Key', detail_actual.PricingTableUniqueKey__c);
        Assert.areEqual(0, detail_actual.CreditWC__c);
        Assert.areEqual('Test Detail Note', detail_actual.Note__c);
        Assert.areEqual(0, detail_actual.UnitPrice__c);
        Assert.areEqual(0, detail_actual.UnitPriceCoefficient__c);
        Assert.areEqual(1, detail_actual.Quantity__c);
        Assert.areEqual(0, detail_actual.CreditWeight__c);
        Assert.areEqual('Test Detail Statement', detail_actual.detailedStatementText__c);
        Assert.areEqual(999, detail_actual.SpecialSpecificationNo__c);
    }

    //Error
    @IsTest
    private static void submitControlCenterDetailsErrorTest() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='TestDetail Name1' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';
        Integer cnt;

        Test.startTest();
        String res_actaul = DetailsInputForControlCenterController.submitControlCenterDetails(details, 'error',cnt);
        Test.stopTest();

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        String res_expect = 'Error';
        Assert.areEqual(res_expect, res_actaul);
    }



    //テストデータ作成
    @TestSetup
    static void createTestData(){
        //PricingTable__c

        Integer recNo = 0;
        List<String> detailName1_List = new List<String>{
            'EMCマルチコントローラ'
            ,'外箱(盤)'
            ,'制御用変圧器単体'
            ,'制御電源用ユニット'
            ,'引込盤'
            ,'引込ユニット'
            ,'非可逆ユニット'
            ,'可逆ユニット'
            ,'スター・デルタユニット'
            ,'MCCBユニット'
            ,'進相コンデンサ'
            ,'リアクトル起動回路'
            ,'インバータユニット'
            ,'高効率コンバータ付インバータユニット'
        };//名称1

        List<String> detailDisplayName_List = new List<String>{
            '電流計  Ａ'
            ,'変流器 （CT）'
            ,'電流計  Ａ  ＋変流器 （CT）'
            ,'零相変流器（ZCT）＋漏電継電器（51G）'
            ,'過電流検出器　ｼｮｯｸﾘﾚｰ (PPC)'
            ,'2Eﾘﾚｰ 過電流検出器 過負荷･欠相'
            ,'3Eﾘﾚｰ 過電流検出器 過負荷･欠相･逆相'
            ,'運転時間計 （Ｈ）'
        };//名称9

        RecordType detailRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Detail' AND SobjectType='PricingTable__c' LIMIT 1];
        List<PricingTable__c> detailPriceTableList = new List<PricingTable__c>();
        for (String name1 : detailName1_List) {
            if (name1 == 'EMCマルチコントローラ') {
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='共通',
                    CategoryName__c='明細',
                    DisplayName__c='TestEMCMultiController',
                    Name1__c=name1,
                    Name2__c=null,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '外箱(盤)'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='共通',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '制御用変圧器単体'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='共通',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2',
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '制御電源用ユニット'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='共通',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '引込盤'){
                String name2 = 'detailName2';
                String name3 = 'detailName3';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='共通',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '引込ユニット'){
                String name2 = 'detailName2';
                String name3 = 'detailName3';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='共通',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '非可逆ユニット'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '可逆ユニット'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == 'スター・デルタユニット'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='TestStarDeltaUnit',
                    Name1__c=name1,
                    Name2__c='detailName2',
                    Name3__c='3コンダクタ',
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2',
                    Name3__c='4コンダクタ',
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == 'MCCBユニット'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='共通',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c='MCCBユニット',
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == 'リアクトル起動回路'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '進相コンデンサ'){
                String name2 = 'detailName2';
                String name3 = 'detailName3';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Frequency__c='50Hz',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == 'インバータユニット'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Frequency__c='50Hz',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '高効率コンバータ付インバータユニット'){
                String name2 = 'detailName2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId = detailRecordType.Id,
                    BU__c = 'S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='コントロールセンタ(C/C)',
                    MinorClassificationName__c='200V',
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Frequency__c='50Hz',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }
        }
        for (String displayname : detailDisplayName_List) {
            if (displayname == '電流計  Ａ') {
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=1,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(displayname == '変流器 （CT）'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=2,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(displayname == '電流計  Ａ  ＋変流器 （CT）'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=3,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(displayname == '零相変流器（ZCT）＋漏電継電器（51G）'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=4,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(displayname == '過電流検出器　ｼｮｯｸﾘﾚｰ (PPC)'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=5,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(displayname == '2Eﾘﾚｰ 過電流検出器 過負荷･欠相'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=6,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(displayname == '3Eﾘﾚｰ 過電流検出器 過負荷･欠相･逆相'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=7,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(displayname == '運転時間計 （Ｈ）'){
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='displayname',
                    RECNOforControlCenter__c=8,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }
        }
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='TestDetail MajorClassificationName__c',
            MajorClassificationCode__c='01',
            MinorClassificationName__c='TestDetail MinorClassificationName__c',
            MinorClassificationCode__c='01',
            CategoryName__c='明細',
            CategoryCode__c='01',
            DisplayName__c='TestDetail',
            Name1__c='TestDetail Name1',
            Name2__c='TestDetail Name2',
            Name3__c='TestDetail Name3',
            Name4__c='TestDetail Name4',
            Name5__c='TestDetail Name5',
            Name6__c='TestDetail Name6',
            Name10__c='TestDetail Name10',
            WC__c=null,
            Price__c=999999,
            Note__c='TestDetail Note__c',
            Weight__c=1,
            detailedStatementText__c='TestDetail detailedStatementText__c',
            SpecialSpecificationNo__c=999
        ));

        insert detailPriceTableList;

        //Account
        Account account = new Account(
            Name = 'Test Account Name'
        );

        //見積
        //施設
        RecordType quoteFacilityRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote1 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 1',
            QuoteNumber__c='1234567890',
            GeneralAdministrativeExpenses__c='23',
            PowerFrequency__c='50Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteFacilityRecordType.Id
        );
        insert quote1;

        //水環境
        RecordType quoteWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote2 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 2',
            QuoteNumber__c='1234567891',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteWaterRecordType.Id
        );
        insert quote2;

        //見積項目
        // 施設
        RecordType deviceFacilityRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Device__c' LIMIT 1];
        Device__c device1 = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567890',
            NETCalculateCategory__c='',
            RecordTypeOfQuote__c='施設',
            MajorClassification__c='コントロールセンタ(C/C)',
            MinorClassification__c='200V',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        insert device1;

        RecordType deviceWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Device__c' LIMIT 1];
        //水環境
        Device__c device3 = new Device__c(
            Quote__c=quote2.Id,
            Name='Test Device Name 3',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567892',
            NETCalculateCategory__c='',
            RecordTypeOfQuote__c='水環境',
            MajorClassification__c='コントロールセンタ(C/C)',
            MinorClassification__c='200V',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceWaterRecordType.Id
        );
        insert device3;

        List<Detail__c> details = new List<Detail__c>();
        //明細
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Detail Name',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='27',
            MajorClassificationName__c='コントロールセンタ(C/C)',
            MinorClassificationCode__c='00',
            MinorClassificationName__c='共通',
            CategoryCode__c='',
            CategoryName__c='',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='Test Detail Name 1',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c='Test Unique Key',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=99999,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='TestDetail',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='27',
            MajorClassificationName__c='コントロールセンタ(C/C)',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='200V',
            CategoryCode__c='',
            CategoryName__c='',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='Test Detail Name 1',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c='Test Unique Key',
            Order__c='Test Order',
            DetailCategory__c='明細', // {仕様, 筐体, 明細, 手入力}
            RECNO__c=1,
            Quantity__c=1,
            WcCoefficient__c=0,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=999,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));
        insert details;
    }
}