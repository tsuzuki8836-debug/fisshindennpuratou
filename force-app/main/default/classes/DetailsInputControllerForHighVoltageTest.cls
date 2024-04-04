@IsTest
private class DetailsInputControllerForHighVoltageTest {

    @IsTest
    private static void getHighVoltageScreenInfoTest() {
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String searchOption = '屋内';
        String inputsRecords = null;

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForHighVoltage.getHighVoltageScreenInfo(true, device.Id, searchOption, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //3) 筐体(高圧受配電盤)
        Map<String, Object> boxTable = (Map<String, Object>)res.get('boxTable');
        if(boxTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '筐体(高圧受配電盤)';
            String secTitle_actual = (String)boxTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)boxTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'用途'},
                        new Map<String, Object>{'colSpanCnt'=>4, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'chassisName3_1'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'母線電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'chassisName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'chassisName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)boxTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }

            //Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>1, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'chassisName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>1, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'chassisName2_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)boxTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_Case.split('\r\n');
            List<Object> noteList_actual = (List<Object>)boxTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //5) 断路器(DS)
        Map<String, Object> disconnectorTable = (Map<String, Object>)res.get('disconnectorTable');
        if(disconnectorTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '断路器(DS)';
            String secTitle_actual = (String)disconnectorTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '＊通常は手動リンク';
            String comment_actual = (String)disconnectorTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'仕様'},
                        new Map<String, Object>{'colSpanCnt'=>4, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_1'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)disconnectorTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)disconnectorTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)disconnectorTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //6) 真空遮断器(VCB)
        Map<String, Object> vcBreakerTable = (Map<String, Object>)res.get('vcBreakerTable');
        if(vcBreakerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '真空遮断器(VCB)';
            String secTitle_actual = (String)vcBreakerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)vcBreakerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'電圧'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'遮断電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)vcBreakerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'\ndetailName3_1\ndetailName5_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName2_1\nMS-S用'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1\ndetailName5_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)vcBreakerTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)vcBreakerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //7) 屋外用高圧交流ガス負荷開閉器
        Map<String, Object> gasLoadSwitchTable = (Map<String, Object>)res.get('gasLoadSwitchTable');
        if(gasLoadSwitchTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '屋外用高圧交流ガス負荷開閉器';
            String secTitle_actual = (String)gasLoadSwitchTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)gasLoadSwitchTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)gasLoadSwitchTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)gasLoadSwitchTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)gasLoadSwitchTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //8) ヒューズ付負荷開閉器(LBS)
        Map<String, Object> fuseLoadSwitchTable = (Map<String, Object>)res.get('fuseLoadSwitchTable');
        if(fuseLoadSwitchTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'ヒューズ付負荷開閉器(LBS)';
            String secTitle_actual = (String)fuseLoadSwitchTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)fuseLoadSwitchTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'電 流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)fuseLoadSwitchTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)fuseLoadSwitchTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)fuseLoadSwitchTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //9) 気中負荷開閉器(PAS)
        Map<String, Object> airLoadSwitchTable = (Map<String, Object>)res.get('airLoadSwitchTable');
        if(airLoadSwitchTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '気中負荷開閉器(PAS)';
            String secTitle_actual = (String)airLoadSwitchTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = 'detailName3_1';
            String comment_actual = (String)airLoadSwitchTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)airLoadSwitchTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)airLoadSwitchTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)airLoadSwitchTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //10) 取引用計器箱(日東工業)
        Map<String, Object> instrumentBoxTable = (Map<String, Object>)res.get('instrumentBoxTable');
        if(instrumentBoxTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '取引用計器箱(日東工業)';
            String secTitle_actual = (String)instrumentBoxTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)instrumentBoxTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'仕様'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)instrumentBoxTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)instrumentBoxTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)instrumentBoxTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //11)　零相変流器(ZCT):高圧
        Map<String, Object> zeroPhaseCurrentTransformerTable = (Map<String, Object>)res.get('zeroPhaseCurrentTransformerTable');
        if(zeroPhaseCurrentTransformerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '零相変流器(ZCT):高圧';
            String secTitle_actual = (String)zeroPhaseCurrentTransformerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)zeroPhaseCurrentTransformerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'過電流倍数'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'2,000 以上'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'数量'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'一次電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)zeroPhaseCurrentTransformerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)zeroPhaseCurrentTransformerTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)zeroPhaseCurrentTransformerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //13) 避雷器(LA)
        Map<String, Object> lightningArresterTable = (Map<String, Object>)res.get('lightningArresterTable');
        if(lightningArresterTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '避雷器(LA)';
            String secTitle_actual = (String)lightningArresterTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)lightningArresterTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'電圧'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'放電電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)lightningArresterTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)lightningArresterTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_LA.split('\r\n');
            List<Object> noteList_actual = (List<Object>)lightningArresterTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //15) 計器用変圧器(VT､PT)ヒューズ付
        Map<String, Object> instrumentTransformerTable = (Map<String, Object>)res.get('instrumentTransformerTable');
        if(instrumentTransformerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '計器用変圧器(VT､PT)ヒューズ付';
            String secTitle_actual = (String)instrumentTransformerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)instrumentTransformerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'電圧'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'相数'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'放電電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)instrumentTransformerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'detailName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)instrumentTransformerTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)instrumentTransformerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //16) 零相変成器(ZPC､ZPD)
        Map<String, Object> zeroPhaseTransformerTable = (Map<String, Object>)res.get('zeroPhaseTransformerTable');
        if(zeroPhaseTransformerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '零相変成器(ZPC、ZPD)';
            String secTitle_actual = (String)zeroPhaseTransformerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)zeroPhaseTransformerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'電圧'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'本体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'本体+引出装置'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)zeroPhaseTransformerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)zeroPhaseTransformerTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_ZPC.split('\r\n');
            List<Object> noteList_actual = (List<Object>)zeroPhaseTransformerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //18) 接地形計器用変圧器ヒューズ付(ZPT、GPT）
        Map<String, Object> groundedInstrumentTransformerTable = (Map<String, Object>)res.get('groundedInstrumentTransformerTable');
        if(groundedInstrumentTransformerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '接地形計器用変圧器ヒューズ付(ZPT、GPT）';
            String secTitle_actual = (String)groundedInstrumentTransformerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)groundedInstrumentTransformerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'電圧仕様'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'本体'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'本体+引出装置'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)groundedInstrumentTransformerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)groundedInstrumentTransformerTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_ZPT.split('\r\n');
            List<Object> noteList_actual = (List<Object>)groundedInstrumentTransformerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //20) 計器用変流器(CT):高圧
        Map<String, Object> currentTransformerTable = (Map<String, Object>)res.get('currentTransformerTable');
        if(currentTransformerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '計器用変流器(CT):高圧';
            String secTitle_actual = (String)currentTransformerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '300A以下：定格電流不明時に採用';
            String comment_actual = (String)currentTransformerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);

            //Check [headerList][bodyList]
            List<Map<String, Object>> multiTable_expect = new List<Map<String, Object>>{
                new Map<String, List<Object>>{
                    'headerList'=>new List<Object>{
                        new Map<String, List<Object>>{
                            'cellList'=>new List<Object>{
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'一次電流'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'二次電流'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName1_1'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName1_2'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                            }
                        }
                    },
                    'bodyList'=>new List<Object>{
                        new Map<String, List<Object>>{
                            'cellList'=>new List<Object>{
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_2'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_2'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                            }
                        }
                    }
                },
                new Map<String, List<Object>>{
                    'headerList'=>new List<Object>{
                        new Map<String, List<Object>>{
                            'cellList'=>new List<Object>{
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'一次電流'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'二次電流'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'MS-S用ワイドレンジCT'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                            }
                        }
                    },
                    'bodyList'=>new List<Object>{
                        new Map<String, List<Object>>{
                            'cellList'=>new List<Object>{
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'detailName3_1'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'detailName3_2'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                            }
                        },
                        new Map<String, List<Object>>{
                            'cellList'=>new List<Object>{
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_2'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                                new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null}
                            }
                        }
                    }
                }
            };

            List<Object> multiTable_actual = (List<Object>)currentTransformerTable.get('multiTable');
            for(Integer t=0; t<multiTable_actual.size(); t++) {
                Map<String, Object> tempTable_expect = (Map<String, Object>)multiTable_expect.get(t);
                Map<String, Object> tempTable_actual = (Map<String, Object>)multiTable_actual.get(t);

                //Check [headerList]
                List<Object> headerList_expectList = (List<Object>)tempTable_expect.get('headerList');
                List<Object> headerList_actualList = (List<Object>)tempTable_actual.get('headerList');

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
                List<Object> bodyList_expectList = (List<Object>)tempTable_expect.get('bodyList');
                List<Object> bodyList_actualList = (List<Object>)tempTable_actual.get('bodyList');

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
            }

            //Check [noteList]
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_CT.split('\r\n');
            List<Object> noteList_actual = (List<Object>)currentTransformerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //22) 負荷開閉器類LBS(LDS)
        Map<String, Object> loadSwitchsTable = (Map<String, Object>)res.get('loadSwitchsTable');
        if(loadSwitchsTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '負荷開閉器類LBS(LDS)';
            String secTitle_actual = (String)loadSwitchsTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)loadSwitchsTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'種別及び仕様'},
                        new Map<String, Object>{'colSpanCnt'=>4, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>4, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName5_1'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName4_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)loadSwitchsTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>null},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)loadSwitchsTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)loadSwitchsTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //23) 変圧器収納盤(高圧)
        Map<String, Object> transformerStorageBoardTable = (Map<String, Object>)res.get('transformerStorageBoardTable');
        if(transformerStorageBoardTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '変圧器収納盤(高圧)';
            String secTitle_actual = (String)transformerStorageBoardTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)transformerStorageBoardTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'変圧器容量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'標準盤外形寸法'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)transformerStorageBoardTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'chassisName3_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'chassisName4_2'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)transformerStorageBoardTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_TransformerStorageBoard.split('\r\n');
            List<Object> noteList_actual = (List<Object>)transformerStorageBoardTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //25) ネットワークリレー
        Map<String, Object> networkRelayMulticapTable = (Map<String, Object>)res.get('networkRelayMulticapTable');
        if(networkRelayMulticapTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'ネットワークリレー';
            String secTitle_actual = (String)networkRelayMulticapTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)networkRelayMulticapTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'型名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)networkRelayMulticapTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)networkRelayMulticapTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)networkRelayMulticapTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //26) ネットワークVT
        Map<String, Object> networkVTTable = (Map<String, Object>)res.get('networkVTTable');
        if(networkVTTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'ネットワークVT';
            String secTitle_actual = (String)networkVTTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)networkVTTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'機器構成'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)networkVTTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)networkVTTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)networkVTTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //27) ネットワークCT
        Map<String, Object> networkCTTable = (Map<String, Object>)res.get('networkCTTable');
        if(networkCTTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'ネットワークCT';
            String secTitle_actual = (String)networkCTTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)networkCTTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'機器構成'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)networkCTTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>1, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)networkCTTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)networkCTTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //28) 合成CT(高圧/低圧)
        Map<String, Object> compositeCTHighAndLowTable = (Map<String, Object>)res.get('compositeCTHighAndLowTable');
        if(compositeCTHighAndLowTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '合成CT(高圧/低圧)';
            String secTitle_actual = (String)compositeCTHighAndLowTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)compositeCTHighAndLowTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)compositeCTHighAndLowTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)compositeCTHighAndLowTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)compositeCTHighAndLowTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //29) プロテクタヒューズ
        Map<String, Object> protectorFuseTable = (Map<String, Object>)res.get('protectorFuseTable');
        if(protectorFuseTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'プロテクタヒューズ';
            String secTitle_actual = (String)protectorFuseTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)protectorFuseTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)protectorFuseTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)protectorFuseTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)protectorFuseTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //30) テイクオフヒューズ
        Map<String, Object> takeOffFuseTable = (Map<String, Object>)res.get('takeOffFuseTable');
        if(takeOffFuseTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'テイクオフヒューズ';
            String secTitle_actual = (String)takeOffFuseTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)takeOffFuseTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)takeOffFuseTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)takeOffFuseTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_TakeOffFuse.split('\r\n');
            List<Object> noteList_actual = (List<Object>)takeOffFuseTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //32) 計器・保護継電器・変換器
        Map<String, Object> meterTableTable = (Map<String, Object>)res.get('meterTableTable');
        if(meterTableTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '計器・保護継電器・変換器';
            String secTitle_actual = (String)meterTableTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)meterTableTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'品名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'記号'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)meterTableTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName1_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)meterTableTable.get('bodyList');
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
            List<String> noteList_expect = System.Label.Annotation_HighVoltageDistributionBoard_Meter.split('\r\n');
            List<Object> noteList_actual = (List<Object>)meterTableTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //34) 変換器(トランスデューサ:T/D)
        Map<String, Object> transducerTable = (Map<String, Object>)res.get('transducerTable');
        if(transducerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '変換器(トランスデューサ:T/D)';
            String secTitle_actual = (String)transducerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)transducerTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'用途'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'記号'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)transducerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)transducerTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)transducerTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //35) MELPRO-Dシリーズ
        Map<String, Object> MELPRODSeriesTable = (Map<String, Object>)res.get('MELPRODSeriesTable');
        if(MELPRODSeriesTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'MELPRO-Dシリーズ';
            String secTitle_actual = (String)MELPRODSeriesTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)MELPRODSeriesTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'形名'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'内蔵要素'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)MELPRODSeriesTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName3_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)MELPRODSeriesTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)MELPRODSeriesTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //36) MP11A(マルチリレー)
        Map<String, Object> mp11MultiRelayTable = (Map<String, Object>)res.get('mp11MultiRelayTable');
        if(mp11MultiRelayTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'MP11A(マルチリレー)';
            String secTitle_actual = (String)mp11MultiRelayTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)mp11MultiRelayTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'仕様・型番'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)mp11MultiRelayTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };           

            List<Object> bodyList_actualList = (List<Object>)mp11MultiRelayTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)mp11MultiRelayTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
    }

    @IsTest
    private static void getHighVoltageScreenInfoInputDataTest() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='屋外用高圧交流ガス負荷開閉器' LIMIT 1];

        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String searchOption = '屋内';
        String inputsRecords = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputControllerForHighVoltage.getHighVoltageScreenInfo(true, device.Id, searchOption, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //7) 屋外用高圧交流ガス負荷開閉器
        Map<String, Object> gasLoadSwitchTable = (Map<String, Object>)res.get('gasLoadSwitchTable');
        if(gasLoadSwitchTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '屋外用高圧交流ガス負荷開閉器';
            String secTitle_actual = (String)gasLoadSwitchTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);
            //Check [comment]
            String comment_expect = '';
            String comment_actual = (String)gasLoadSwitchTable.get('comment');
            Assert.areEqual(comment_expect, comment_actual);
            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'定格電流'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };

            List<Object> headerList_actualList = (List<Object>)gasLoadSwitchTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'detailName2_1'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>1}}
                    }
                }
            };

            List<Object> bodyList_actualList = (List<Object>)gasLoadSwitchTable.get('bodyList');
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
            List<Object> noteList_actual = (List<Object>)gasLoadSwitchTable.get('noteList');
            Assert.areEqual(noteList_expect, noteList_actual);
        }
    }

    //Chassis
    @IsTest
    private static void submitHighVoltageDetails1Test() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='TestChassis Name1' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        String res_actaul = DetailsInputControllerForHighVoltage.submitHighVoltageDetails(details, device.Id);
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
                                    ,Name6__c
                                    ,Name7__c
                                    ,Name8__c
                                    ,Name9__c
                                    ,Name10__c
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
                                    WHERE Device__r.Name='Test Device Name 1' AND Name = 'Test Chassis Name 1'
                                    LIMIT 1];

        // Test data when input data testing
        Assert.areEqual(device.Id, detail_actual.Device__c);
        Assert.areEqual('Test Chassis Name 1', detail_actual.Name);
        Assert.areEqual('Test Detail Name 1', detail_actual.Name1__c);
        Assert.areEqual('Test Detail Name 2', detail_actual.Name2__c);
        Assert.areEqual('Test Detail Name 3', detail_actual.Name3__c);
        Assert.areEqual('Test Detail Name 4', detail_actual.Name4__c);
        Assert.areEqual('Test Detail Name 5', detail_actual.Name5__c);
        Assert.areEqual('Test Detail Name 6', detail_actual.Name6__c);
        Assert.areEqual('Test Detail Name 7', detail_actual.Name7__c);
        Assert.areEqual('Test Detail Name 8', detail_actual.Name8__c);
        Assert.areEqual('Test Detail Name 9', detail_actual.Name9__c);
        Assert.areEqual(null, detail_actual.Name10__c);
        Assert.areEqual('筐体', detail_actual.DetailCategory__c);
        Assert.areEqual(0, detail_actual.WcCalculationRate__c);
        Assert.areEqual('特高', detail_actual.MajorClassificationName__c);
        Assert.areEqual('21', detail_actual.MajorClassificationCode__c);
        Assert.areEqual('特高監視盤', detail_actual.MinorClassificationName__c);
        Assert.areEqual('04', detail_actual.MinorClassificationCode__c);
        Assert.areEqual(null, detail_actual.CategoryCode__c);
        Assert.areEqual('Test Unique Key', detail_actual.PricingTableUniqueKey__c);
        Assert.areEqual(0, detail_actual.CreditWC__c);
        Assert.areEqual('Test Detail Note', detail_actual.Note__c);
        Assert.areEqual(0, detail_actual.UnitPrice__c);
        Assert.areEqual(0, detail_actual.UnitPriceCoefficient__c);
        Assert.areEqual(1, detail_actual.Quantity__c);
        Assert.areEqual(0, detail_actual.CreditWeight__c);
        Assert.areEqual('Test Detail Statement', detail_actual.detailedStatementText__c);
        Assert.areEqual(0, detail_actual.SpecialSpecificationNo__c);
    }

    //Detail
    @IsTest
    private static void submitHighVoltageDetails2Test() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='TestDetail Name1' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        String res_actaul = DetailsInputControllerForHighVoltage.submitHighVoltageDetails(details, device.Id);
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
        Assert.areEqual('TestDetail Name1', detail_actual.Name1__c);
        Assert.areEqual('TestDetail Name2', detail_actual.Name2__c);
        Assert.areEqual('TestDetail Name3', detail_actual.Name3__c);
        Assert.areEqual('TestDetail Name4', detail_actual.Name4__c);
        Assert.areEqual('明細', detail_actual.DetailCategory__c);
        Assert.areEqual(null, detail_actual.WcCalculationRate__c);
        Assert.areEqual('TestDetail MajorClassificationName__c', detail_actual.MajorClassificationName__c);
        Assert.areEqual('01', detail_actual.MajorClassificationCode__c);
        Assert.areEqual('TestDetail MinorClassificationName__c', detail_actual.MinorClassificationName__c);
        Assert.areEqual('01', detail_actual.MinorClassificationCode__c);
        Assert.areEqual('01', detail_actual.CategoryCode__c);
        Assert.areEqual('明細STestDetail MajorClassificationName__cTestDetail MinorClassificationName__c明細TestDetail Name1TestDetail Name2TestDetail Name3TestDetail Name4TestDetail Name5TestDetail Name6TestDetail Name10', detail_actual.PricingTableUniqueKey__c);
        Assert.areEqual(null, detail_actual.CreditWC__c);
        Assert.areEqual('TestDetail Note__c', detail_actual.Note__c);
        Assert.areEqual(999999, detail_actual.UnitPrice__c);
        Assert.areEqual(null, detail_actual.UnitPriceCoefficient__c);
        Assert.areEqual(1, detail_actual.Quantity__c);
        Assert.areEqual(1.00, detail_actual.CreditWeight__c);
        Assert.areEqual('TestDetail detailedStatementText__c', detail_actual.detailedStatementText__c);
        Assert.areEqual(999, detail_actual.SpecialSpecificationNo__c);
    }

    //Error
    @IsTest
    private static void submitHighVoltageDetailsErrorTest() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='TestDetail Name1' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        String res_actaul = DetailsInputControllerForHighVoltage.submitHighVoltageDetails(details, 'error');
        Test.stopTest();

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        String res_expect = 'Error';
        Assert.areEqual(res_expect, res_actaul);
    }

    @IsTest
    private static void getAllPriceFor1InputOnlyTest() {

        Map<Id, String> combinationTable_Map = new Map<Id, String>();
        Map<Id, PricingTable__c> priceMap = new Map<Id, PricingTable__c>([SELECT Id,
                                                                                UniqueKey__c,
                                                                                Name,
                                                                                Name1__c,
                                                                                Name2__c,
                                                                                Name4__c,
                                                                                RecordType.DeveloperName,
                                                                                MajorClassificationName__c,//大分類
                                                                                MinorClassificationName__c, //小分類
                                                                                Price__c //単価
                                                                            FROM PricingTable__c
                                                                            WHERE (
                                                                                MajorClassificationName__c = '高圧受配電盤'
                                                                                AND RecordType.DeveloperName = 'Detail'
                                                                                AND (
                                                                                    Name1__c = '断路器(DS)'
                                                                                    OR Name1__c = '真空遮断器(VCB)'
                                                                                )
                                                                            )
                                                                            ORDER BY RECNO__c
                                                                        ]);
        for(Id priceKey : priceMap.keySet()){
            PricingTable__c price = priceMap.get(priceKey);
            if(price.MajorClassificationName__c=='高圧受配電盤' && price.RecordType.DeveloperName=='Detail' && (price.Name1__c == '断路器(DS)' || price.Name1__c == '真空遮断器(VCB)')) {
                combinationTable_Map.put(price.Id, price.Name1__c == '断路器(DS)' ? 'DS@@'+price.Name2__c.remove('以下'):'VCB@@'+price.Name4__c.remove('定格電流:'));
            }
        }

        String res_expect = JSON.serialize(new Map<String, Object>{
            'combinationTable'=>combinationTable_Map
        });

        Test.startTest();
        String res_actaul = DetailsInputControllerForHighVoltage.getAllPriceFor1InputOnly();
        Test.stopTest();

        Assert.areEqual(res_expect, res_actaul);
    }

    @TestSetup
    static void createTestData(){
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        //                                    PricingTable__c                                       //
        //////////////////////////////////////////////////////////////////////////////////////////////

        Integer recNo = 0;
        List<String> chassisName1_list = new List<String>{
            '屋内',
            '屋外',
            '屋内FF',
            '屋外FF'
        };
        List<String> chassisName2_list = new List<String>{
            'chassisName2_1',
            'chassisName2_2'
        };
        List<String> chassisName3_list = new List<String>{
            'chassisName3_1'
        };
        List<String> chassisName4_list = new List<String>{
            'chassisName4_1',
            'chassisName4_2'
        };
        
        
        List<String> chassisName1_list2 = new List<String>{
            '変圧器収納盤(高圧)'
        };
        List<String> chassisName2_list2 = new List<String>{
            '屋内',
            '屋外',
            '屋内FF',
            '屋外FF'
        };
        List<String> chassisName3_list2 = new List<String>{
            'chassisName3_2'
        };
        List<String> chassisName4_list2 = new List<String>{
            'chassisName4_2'
        };

        List<String> detailName1_list = new List<String>{
            '断路器(DS)'
            ,'真空遮断器(VCB)'
            ,'屋外用高圧交流ガス負荷開閉器'
            ,'気中負荷開閉器(PAS)'
            ,'取引用計器箱(日東工業)'
            ,'避雷器(LA)'
            ,'計器用変圧器(VT､PT)ヒューズ付'
            ,'零相変成器(ZPC､ZPD)'
            ,'接地形計器用変圧器ヒューズ付'
            ,'負荷開閉器類'
            ,'ネットワークリレー'
            ,'ネットワークVT'
            ,'ネットワークCT'
            ,'合成CT(高圧/低圧)'
        };

        List<String> detailName1_list2 = new List<String>{
            'ヒューズ付負荷開閉器'
            ,'零相変流器(ZCT):高圧'
            ,'変換器(トランスデューサ:T/D)'
            ,'プロテクタヒューズ'
            ,'テイクオフヒューズ'
            ,'MELPRO-Dシリーズ'
            ,'MP11A(マルチリレー)'
        };


        //Create Test Data for [RecordType.DeveloperName = 'Chassis']
        RecordType chassisRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Chassis' AND SobjectType='PricingTable__c' LIMIT 1];
        List<PricingTable__c> chassisPriceTableList = new List<PricingTable__c>();
        for(String name1 : chassisName1_list) {
            for(String name2 : chassisName2_list) {
                for(String name3 : chassisName3_list) {
                    for(String name4 : chassisName4_list) {
                        chassisPriceTableList.add(new PricingTable__c(
                            RecordTypeId=chassisRecordType.Id,
                            BU__c='S',
                            RECNo__c=++recNo,
                            MajorClassificationName__c='高圧受配電盤',
                            MinorClassificationName__c=null,
                            CategoryName__c='筐体',
                            DisplayName__c='筐体',
                            Name1__c=name1,
                            Name2__c=name2,
                            Name3__c=name3,
                            Name4__c=name4,
                            Name5__c=null,
                            Name6__c=null,
                            Name10__c=null,
                            WC__c=null,
                            Price__c=999999,
                            Note__c=''
                        ));
                    }
                }
            }
        }
        for(String name1 : chassisName1_list2) {
            for(String name2 : chassisName2_list2) {
                for(String name3 : chassisName3_list2) {
                    for(String name4 : chassisName4_list2) {
                        chassisPriceTableList.add(new PricingTable__c(
                            RecordTypeId=chassisRecordType.Id,
                            BU__c='S',
                            RECNo__c=++recNo,
                            MajorClassificationName__c='変圧器',
                            MinorClassificationName__c='変圧器収納盤',
                            CategoryName__c='筐体',
                            DisplayName__c='変圧器収納',
                            Name1__c=name1,
                            Name2__c=name2,
                            Name3__c=name3,
                            Name4__c=name4,
                            Name5__c=null,
                            Name6__c=null,
                            Name10__c=null,
                            WC__c=null,
                            Price__c=999999,
                            Note__c=''
                        ));
                    }
                }
            }
        }
        insert chassisPriceTableList;

        //Create Test Data for [RecordType.DeveloperName = 'Detail']
        RecordType detailRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Detail' AND SobjectType='PricingTable__c' LIMIT 1];
        List<PricingTable__c> detailPriceTableList = new List<PricingTable__c>();
        for(String name1 : detailName1_list) {
            if(name1 == '断路器(DS)') {
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_1',
                    Name4__c='detailName4_1',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_1',
                    Name4__c='detailName4_2',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_2',
                    Name3__c='detailName3_1',
                    Name4__c='detailName4_1',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '真空遮断器(VCB)') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                String name4 = 'detailName4_1';
                String name5 = 'detailName5_1';
                String name6_1 = 'detailName6_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=name4,
                    Name5__c=name5,
                    Name6__c=name6_1,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                String name6_2 = 'MS-S用';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=name4,
                    Name5__c=name5,
                    Name6__c=name6_2,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '屋外用高圧交流ガス負荷開閉器') {
                String name2 = 'detailName2_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '気中負荷開閉器(PAS)') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '取引用計器箱(日東工業)') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '避雷器(LA)') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                String name4 = 'detailName4_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=name4,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '計器用変圧器(VT､PT)ヒューズ付') {
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_1',
                    Name4__c='detailName4_1',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_2',
                    Name4__c='detailName4_1',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_1相(detailName3_2)',
                    Name4__c='detailName4_2',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '零相変成器(ZPC､ZPD)') {
                String name2_1 = 'detailName2_1';
                String name3 = 'detailName3_1';
                String name4 = 'detailName4_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2_1,
                    Name3__c=name3,
                    Name4__c=name4,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                String name2_2 = 'detailName2_2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2_2,
                    Name3__c=name3,
                    Name4__c=name4,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                String name4_2 = 'detailName4_2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2_1,
                    Name3__c=name3,
                    Name4__c=name4_2,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '接地形計器用変圧器ヒューズ付') {
                String name2 = 'detailName2_1';
                String name3_1 = 'detailName3_1';
                String name4 = 'detailName4_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3_1,
                    Name4__c=name4,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                String name3_2 = 'detailName3_2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3_2,
                    Name4__c=name4,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                String name4_2 = 'detailName4_2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3_1,
                    Name4__c=name4_2,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '負荷開閉器類') {
                String name2 = 'detailName2_1';
                String name3_1 = 'detailName3_1';
                String name4_1 = 'detailName4_1';
                String name5 = 'detailName5_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3_1,
                    Name4__c=name4_1,
                    Name5__c=name5,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                String name3_2 = 'detailName3_2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3_2,
                    Name4__c=name4_1,
                    Name5__c=name5,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                String name4_2 = 'detailName4_2';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3_1,
                    Name4__c=name4_2,
                    Name5__c=name5,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == 'ネットワークリレー') {
                String name2 = 'detailName2_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == 'ネットワークVT') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == 'ネットワークCT') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == '合成CT(高圧/低圧)') {
                String name2 = 'detailName2_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='高圧受配電盤',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }
        }
        for(String name1 : detailName1_list2) {
            if(name1 == 'ヒューズ付負荷開閉器') {
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_1',
                    Name4__c='detailName4_1',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_2',
                    Name4__c='detailName4_1',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c='detailName2_1',
                    Name3__c='detailName3_1',
                    Name4__c='detailName4_2',
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }  else if(name1 == '零相変流器(ZCT):高圧') {
                String name2 = 'detailName2_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }else if(name1 == '変換器(トランスデューサ:T/D)') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == 'MELPRO-Dシリーズ') {
                String name2 = 'detailName2_1';
                String name3 = 'detailName3_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=name3,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == 'MP11A(マルチリレー)') {
                String name2 = 'detailName2_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == 'プロテクタヒューズ') {
                String name2 = 'detailName2_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            } else if(name1 == 'テイクオフヒューズ') {
                String name2 = 'detailName2_1';
                detailPriceTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id,
                    BU__c='S',
                    RECNo__c=++recNo,
                    MajorClassificationName__c='共通機器',
                    MinorClassificationName__c=null,
                    CategoryName__c='明細',
                    DisplayName__c='',
                    Name1__c=name1,
                    Name2__c=name2,
                    Name3__c=null,
                    Name4__c=null,
                    Name5__c=null,
                    Name6__c=null,
                    Name10__c=null,
                    WC__c=null,
                    Price__c=999999,
                    Note__c=''
                ));
            }
        }

        //計器用変流器(CT):高圧
        String other1_name10 = '計器用変流器(CT):高圧';
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='共通機器',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c='MS-S用ワイドレンジCT',
            Name2__c='detailName2_1',
            Name3__c='detailName3_1',
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=other1_name10,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='共通機器',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c='MS-S用ワイドレンジCT',
            Name2__c='detailName2_1',
            Name3__c='detailName3_2',
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=other1_name10,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='共通機器',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c='MS-S用ワイドレンジCT',
            Name2__c='detailName2_2',
            Name3__c='detailName3_1',
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=other1_name10,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='共通機器',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c='detailName1_1',
            Name2__c='detailName2_2',
            Name3__c='detailName3_2',
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=other1_name10,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='共通機器',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c='detailName1_1',
            Name2__c='detailName2_2',
            Name3__c='detailName3_2',
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=other1_name10,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='共通機器',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c='detailName1_2',
            Name2__c='detailName2_2',
            Name3__c='detailName3_1',
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=other1_name10,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));

        //計器・保護継電器・変換器
        String otherX_name1 = 'detailName1_1';
        String otherX_name2 = 'detailName2_1';
        String otherX_name10 = '計器・保護継電器・変換器';
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='共通機器',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c=otherX_name1,
            Name2__c=otherX_name2,
            Name3__c=null,
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=otherX_name10,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));
        //////////////////////////////////////////////////////////////////////////////////////////////
    
        // Test data when input data testing
        detailPriceTableList.add(new PricingTable__c(
            RecordTypeId=chassisRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='TestChassis MajorClassificationName__c',
            MajorClassificationCode__c='01',
            MinorClassificationName__c='TestChassis MinorClassificationName__c',
            MinorClassificationCode__c='01',
            CategoryName__c='筐体',
            CategoryCode__c='01',
            DisplayName__c='筐体',
            Name1__c='TestChassis Name1',
            Name2__c='TestChassis Name2',
            Name3__c='TestChassis Name3',
            Name4__c='TestChassis Name4',
            Name5__c='TestChassis Name5',
            Name6__c='TestChassis Name6',
            Name10__c='TestChassis Name10',
            WC__c=null,
            Price__c=999999,
            Note__c='TestChassis Note__c',
            Weight__c=1,
            detailedStatementText__c='TestChassis detailedStatementText__c',
            SpecialSpecificationNo__c=999
        ));
        // Test data when input data testing
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
        //////////////////////////////////////////////////////////////////////////////////////////////

        insert detailPriceTableList;

        //Delete to test blank data
        List<PricingTable__c> toDelete = [SELECT Id FROM PricingTable__c
                                            WHERE Name2__c = 'chassisName2_2'
                                                AND Name3__c = 'chassisName3_1'
                                                AND Name4__c = 'chassisName4_2'
                                        ];
        delete toDelete;

        //////////////////////////////////////////////////////////////////////////////////////////////
        //                    Account, Quote__c, Device__c, Detail__c                               //
        //////////////////////////////////////////////////////////////////////////////////////////////

        Account account = new Account(
            Name='Test Account Name'
        );
        insert account;

        // 施設
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

        // 水環境
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

        Quote__c quote3 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 3',
            QuoteNumber__c='1234567892',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quoteWaterRecordType.Id
        );
        insert quote3;

        // 官需
        RecordType quotePDemandRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='官需' AND SobjectType='Quote__c' LIMIT 1];
        Quote__c quote4 = new Quote__c(
            Account__c=account.Id,
            Subject__c='Test Quote Subject 4',
            QuoteNumber__c='1234567893',
            GeneralAdministrativeExpenses__c='25',
            PowerFrequency__c='60Hz', // {50Hz, 60Hz}
            OutputSheetName__c='TestQuoteOutputSheetName',
            RecordTypeId=quotePDemandRecordType.Id
        );
        insert quote4;

        // 施設
        RecordType deviceFacilityRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='施設' AND SobjectType='Device__c' LIMIT 1];
        Device__c device1 = new Device__c(
            Quote__c=quote1.Id,
            Name='Test Device Name 1',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567890',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='施設', // {施設, 水環境, 官需}
            MajorClassification__c='特高',
            MinorClassification__c='特高監視盤',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceFacilityRecordType.Id
        );
        insert device1;

        // 水環境
        RecordType deviceWaterRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='水環境' AND SobjectType='Device__c' LIMIT 1];
        Device__c device2 = new Device__c(
            Quote__c=quote2.Id,
            Name='Test Device Name 2',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567891',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='水環境', // {施設, 水環境, 官需}
            MajorClassification__c='低圧・現場・ﾘﾚｰ・ACB盤',
            MinorClassification__c='低圧盤',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceWaterRecordType.Id
        );
        insert device2;

        Device__c device3 = new Device__c(
            Quote__c=quote3.Id,
            Name='Test Device Name 3',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567892',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='水環境', // {施設, 水環境, 官需}
            MajorClassification__c='コントロールセンタ（C/C)',
            MinorClassification__c='400V',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=deviceWaterRecordType.Id
        );
        insert device3;
        
        // 官需
        RecordType devicePDemandRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name='官需' AND SobjectType='Device__c' LIMIT 1];
        Device__c device4 = new Device__c(
            Quote__c=quote4.Id,
            Name='Test Device Name 4',
            Note__c='Test Device Note',
            Quantity__c='1',
            Unit__c='piece',
            QuoteSpecificationNumber__c='1234567894',
            NETCalculateCategory__c='', // {受変電, UPS, 自家発, ビルシ, 映像, 労務}
            RecordTypeOfQuote__c='官需', // {施設, 水環境, 官需}
            MajorClassification__c='無線装置（テレメータ･テレコントロール用）',
            MinorClassification__c='70MHz帯無線装置(テレメータ･テレコントロール用)',
            ClientAnswerWeight_free__c=0,
            CreditWeight__c=0,
            PriceCoefficient__c=0,
            DisplayOrder__c=1,
            EquipManageCostTarget__c=false,
            GeneralAdminExpensesExistence__c=false,
            RecordTypeId=devicePDemandRecordType.Id
        );
        insert device4;

        List<Detail__c> details = new List<Detail__c>();
        // 筐体
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Chassis Name 1',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='04',
            MinorClassificationName__c='特高監視盤',
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
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Detail Name 2',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='04',
            MinorClassificationName__c='特高監視盤',
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
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        // 筐体
        details.add(new Detail__c(
            Device__c=device2.Id,
            PricingTable__c=null,
            Name='Test Detail Name 3',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='05',
            MajorClassificationName__c='低圧・現場・ﾘﾚｰ・ACB盤',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='低圧盤',
            CategoryCode__c='01',
            CategoryName__c='筐体',
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
        details.add(new Detail__c(
            Device__c=device2.Id,
            PricingTable__c=null,
            Name='Test Detail Name 4',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='05',
            MajorClassificationName__c='低圧・現場・ﾘﾚｰ・ACB盤',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='低圧盤',
            CategoryCode__c='01',
            CategoryName__c='筐体',
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
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        //  明細
        details.add(new Detail__c(
            Device__c=device4.Id,
            PricingTable__c=null,
            Name='Test Detail Name 5',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='41',
            MajorClassificationName__c='無線装置（ﾃﾚﾒｰﾀ･ﾃﾚｺﾝﾄﾛｰﾙ用）',
            MinorClassificationCode__c='01',
            MinorClassificationName__c='70ＭＨｚ帯無線装置（ﾃﾚﾒｰﾀ･ﾃﾚｺﾝﾄﾛｰﾙ用）',
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
            WcCoefficient__c=null,
            UnitPriceCoefficient__c=0,
            CreditWeight__c=0,
            SpecialSpecificationNo__c=0,
            WcCalculationRate__c=0,
            ProvisionUnitPrice__c=0,
            UnitPrice__c=0,
            CreditWC__c=0
        ));

        insert details;
    }
}