@IsTest
private class DetailsInputForStorageBoardTest {
    //変成機器：低圧
    //
    @IsTest
    private static void getStorageBoardScreenInfoTest() {
        List<PricingTable__c> priceList = [SELECT Id FROM PricingTable__c WHERE (RECNo__c = 2 AND Name1__c='変圧器収納盤(高圧)' AND Name2__c='屋外') OR (RECNo__c = 2 AND Name1__c='変圧器収納盤(低圧)' AND Name2__c='屋外')];
        Device__c device = [SELECT Id FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String searchOption = '屋内';
        String inputsRecords = '[{"Id":"' + priceList.get(0).Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}, {"Id":"' + priceList.get(1).Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote__c' and name = '施設']; 
        Device__c dv = [SELECT Id FROM Device__c WHERE Quote__r.QuoteNumber__c='1234567890' LIMIT 1];
        Test.startTest();
        //Parameter :: (String deviceId, String searchOption, String inputsRecords)
        String testRes = DetailsInputForStorageBoardController.getStorageBoardScreenInfo(true ,dv.Id, searchOption, inputsRecords);
        Test.stopTest();

        Map<String, Object> res = (Map<String, Object>)JSON.deserializeUntyped(testRes);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //変成機器：低圧
        Map<String, Object> transformerLowVoltageTable = (Map<String, Object>)res.get('transformerLowVoltageTable');
        if(transformerLowVoltageTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '変成機器：低圧';
            String secTitle_actual = (String)transformerLowVoltageTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

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
            List<Object> headerList_actualList = (List<Object>)transformerLowVoltageTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'CT'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'ZCT+51G'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)transformerLowVoltageTable.get('bodyList');
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

        //ヒューズ付負荷開閉器（LBS)
        Map<String, Object> loadDisconnectorTable = (Map<String, Object>)res.get('loadDisconnectorTable');
        if(loadDisconnectorTable!=null) {
            //Check [secTitle]
            String secTitle_expect = 'ヒューズ付負荷開閉器（LBS)';
            String secTitle_actual = (String)loadDisconnectorTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'電　流'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'ﾌｯｸ操作'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'遠方操作'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)loadDisconnectorTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'60A以下'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>null, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>null, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'100A'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'200A'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)loadDisconnectorTable.get('bodyList');
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

        //変圧器収納盤(高圧)
        Map<String, Object> transformerStoragePanelHighVoltageTable = (Map<String, Object>)res.get('transformerStoragePanelHighVoltageTable');
        if(transformerStoragePanelHighVoltageTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '変圧器収納盤(高圧)　(FFの場合は×0.8とすること)';
            String secTitle_actual = (String)transformerStoragePanelHighVoltageTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'変圧器容量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価  格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'標準盤外形寸法'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>''}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)transformerStoragePanelHighVoltageTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }
    
            PricingTable__c rec = [SELECT Id FROM PricingTable__c WHERE RECNo__c = 1 AND Name1__c='変圧器収納盤(高圧)' AND Name2__c='屋内' LIMIT 1];
            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 3'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 4'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>rec.Id, 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)transformerStoragePanelHighVoltageTable.get('bodyList');
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
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
    
                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }
        }

        //変圧器収納盤(低圧)
        Map<String, Object> transformerStoragePanelLowVoltageTable = (Map<String, Object>)res.get('transformerStoragePanelLowVoltageTable');
        if(transformerStoragePanelLowVoltageTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '変圧器収納盤(低圧)　(FFの場合は×0.8とすること)';
            String secTitle_actual = (String)transformerStoragePanelLowVoltageTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'変圧器容量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価  格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'標準盤外形寸法'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>''}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)transformerStoragePanelLowVoltageTable.get('headerList');
            for(Integer i=0; i<headerList_actualList.size(); i++) {
                Map<String, Object> cell_expect = (Map<String, Object>)headerList_expectList.get(i);
                List<Object> cellList_expect = (List<Object>)cell_expect.get('cellList');
                Map<String, Object> cell_actaul = (Map<String, Object>)headerList_actualList.get(i);
                List<Object> cellList_actaul = (List<Object>)cell_actaul.get('cellList');

                for(Integer j=0; j<cellList_actaul.size(); j++) {
                    System.debug('cellList_expect.get(j)' + cellList_expect.get(j));
                    System.debug('cellList_expect.get(j)' + cellList_actaul.get(j));
                    Assert.areEqual(cellList_expect.get(j), cellList_actaul.get(j));
                }
            }
    
            PricingTable__c rec = [SELECT Id FROM PricingTable__c WHERE RECNo__c = 1 AND Name1__c='変圧器収納盤(低圧)' AND Name2__c='屋内' LIMIT 1];            
            // Check [bodyList]
            List<Object> bodyList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 3'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 4'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>rec.Id, 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)transformerStoragePanelLowVoltageTable.get('bodyList');
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
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
    
                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }
        }

        //接地トランス(GTR)
        Map<String, Object> groundTransformerTable = (Map<String, Object>)res.get('groundTransformerTable');
        if(groundTransformerTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '接地トランス(GTR) (3相､6600/190V､50/60Hz,モールド)';
            String secTitle_actual = (String)groundTransformerTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'容量（ｋVA）'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)groundTransformerTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 3'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)groundTransformerTable.get('bodyList');
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
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
    
                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }
        }

        //中性点付接地トランス(NGR)
        Map<String, Object> groundTransformerWithNeutralPointTable = (Map<String, Object>)res.get('groundTransformerWithNeutralPointTable');
        if(groundTransformerWithNeutralPointTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '中性点付接地トランス(NGR) (3相､6600/190V､50/60Hz,モールド)';
            String secTitle_actual = (String)groundTransformerWithNeutralPointTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'容量（ｋVA）'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)groundTransformerWithNeutralPointTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 3'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)groundTransformerWithNeutralPointTable.get('bodyList');
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
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
    
                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }
        }

        //照明用・建築付帯用トランス
        Map<String, Object> transformersLightingAndBuildingTable = (Map<String, Object>)res.get('transformersLightingAndBuildingTable');
        if(transformersLightingAndBuildingTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '照明用・建築付帯用トランス(単相3線､400,200/100V)';
            String secTitle_actual = (String)transformersLightingAndBuildingTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'容量'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'単相'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'三相'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)transformersLightingAndBuildingTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 3'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)transformersLightingAndBuildingTable.get('bodyList');
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
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
    
                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }
        }

        //耐雷トランス
        Map<String, Object> thunderResistantTable = (Map<String, Object>)res.get('thunderResistantTable');
        if(thunderResistantTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '耐雷TR';
            String secTitle_actual = (String)thunderResistantTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'容量'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'単相'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'三相'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)thunderResistantTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 3'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'0'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)thunderResistantTable.get('bodyList');
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
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
    
                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }
        }

        //高圧盤内照明・電源用トランス
        Map<String, Object> transformerHighVoltagePowerReceivingTable = (Map<String, Object>)res.get('transformerHighVoltagePowerReceivingTable');
        if(transformerHighVoltagePowerReceivingTable!=null) {
            //Check [secTitle]
            String secTitle_expect = '高圧受電用操作トランス(単相2線､6600/105V,モールド)';
            String secTitle_actual = (String)transformerHighVoltagePowerReceivingTable.get('secTitle');
            Assert.areEqual(secTitle_expect, secTitle_actual);

            //Check [headerList]
            List<Object> headerList_expectList = new List<Object>{
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>true, 'rowSpanCnt'=>2, 'value'=>'容量'},
                        new Map<String, Object>{'colSpanCnt'=>2, 'isColSpan'=>true, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'単相2線'}
                    }
                },
                new Map<String, List<Object>>{
                    'cellList'=>new List<Object>{
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'価格'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'数量'}
                    }
                }
            };
            List<Object> headerList_actualList = (List<Object>)transformerHighVoltagePowerReceivingTable.get('headerList');
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
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>false, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'Test Detail Name 3'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>false, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>'999,999'},
                        new Map<String, Object>{'colSpanCnt'=>null, 'isColSpan'=>false, 'isEdit'=>true, 'isRight'=>true, 'isRowSpan'=>false, 'rowSpanCnt'=>null, 'value'=>new Map<String, Object>{'Id'=>'', 'Price'=>999999, 'Quantity'=>null}}
                    }
                }
            };
    
            List<Object> bodyList_actualList = (List<Object>)transformerHighVoltagePowerReceivingTable.get('bodyList');
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
                        Assert.areEqual(expect.get('rowSpanCnt'), actaul.get('rowSpanCnt'));
    
                        Map<String, Object> expect_value = (Map<String, Object>)expect.get('value');
                        Map<String, Object> actaul_value = (Map<String, Object>)actaul.get('value');
                    } else {
                        Assert.areEqual(expect, actaul);
                    }
                }
            }
        }
    }

    //Chassis
    @IsTest
    private static void submitStorageBoardDetails1Test() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='TestChassis Name1' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        String res_actaul = DetailsInputForStorageBoardController.submitStorageBoardDetails(details, device.Id);
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
                                    WHERE Device__r.Name='Test Device Name 1' AND Name = 'Test Detail Name 1'
                                    LIMIT 1];

        // Test data when input data testing
        Assert.areEqual(device.Id, detail_actual.Device__c);
        Assert.areEqual('Test Detail Name 1', detail_actual.Name);
        Assert.areEqual('TestChassis Name1', detail_actual.Name1__c);
        Assert.areEqual('TestChassis Name2', detail_actual.Name2__c);
        Assert.areEqual('TestChassis Name3', detail_actual.Name3__c);
        Assert.areEqual('TestChassis Name4', detail_actual.Name4__c);
        Assert.areEqual('TestChassis Name5', detail_actual.Name5__c);
        Assert.areEqual('TestChassis Name6', detail_actual.Name6__c);
        Assert.areEqual(null, detail_actual.Name7__c);
        Assert.areEqual(null, detail_actual.Name8__c);
        Assert.areEqual(null, detail_actual.Name9__c);
        Assert.areEqual('TestChassis Name10', detail_actual.Name10__c);
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
    private static void submitStorageBoardDetails2Test() {
        PricingTable__c price = [SELECT Id FROM PricingTable__c WHERE Name1__c='耐雷トランス' LIMIT 1];

        Device__c device = [SELECT Id, Quote__c FROM Device__c WHERE Name='Test Device Name 1' LIMIT 1];
        String details = '[{"Id":"' + price.Id + '","Quantity":1,"Price":999999,"UnitPrice":999999}]';

        Test.startTest();
        String res_actaul = DetailsInputForStorageBoardController.submitStorageBoardDetails(details, device.Id);
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
                                    WHERE Device__r.Name='Test Device Name 1' AND Name = '耐雷トランス'
                                    LIMIT 1];

        // Test data when input data testing
        Assert.areEqual(device.Id, detail_actual.Device__c);
        Assert.areEqual('耐雷トランス', detail_actual.Name);
        Assert.areEqual('耐雷トランス', detail_actual.Name1__c);
        Assert.areEqual('Test Detail Name 2', detail_actual.Name2__c);
        Assert.areEqual('Test Detail Name 3', detail_actual.Name3__c);
        Assert.areEqual('単相', detail_actual.Name4__c);
        Assert.areEqual('明細', detail_actual.DetailCategory__c);
        Assert.areEqual(null, detail_actual.WcCalculationRate__c);
        Assert.areEqual('共通機器', detail_actual.MajorClassificationName__c);
        Assert.areEqual(null, detail_actual.MajorClassificationCode__c);
        Assert.areEqual(null, detail_actual.MinorClassificationName__c);
        Assert.areEqual(null, detail_actual.MinorClassificationCode__c);
        Assert.areEqual(null, detail_actual.CategoryCode__c);
        Assert.areEqual(null, detail_actual.CreditWC__c);
        Assert.areEqual(null, detail_actual.Note__c);
        Assert.areEqual(999999, detail_actual.UnitPrice__c);
        Assert.areEqual(null, detail_actual.UnitPriceCoefficient__c);
        Assert.areEqual(1, detail_actual.Quantity__c);
        Assert.areEqual(null, detail_actual.CreditWeight__c);
        Assert.areEqual(null, detail_actual.detailedStatementText__c);
        Assert.areEqual(0, detail_actual.SpecialSpecificationNo__c);
    }

    @TestSetup
    static void makeData(){
        //Create Test Data for [RecordType.DeveloperName = 'Detail']
        RecordType chassisRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Chassis' AND SobjectType='PricingTable__c' LIMIT 1];
        //Create Test Data for [RecordType.DeveloperName = 'Detail']
        RecordType detailRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName='Detail' AND SobjectType='PricingTable__c' LIMIT 1];
        initPricingTableData01(detailRecordType);
        initPricingTableData02(detailRecordType);
        initPricingTableData03(chassisRecordType);
        initPricingTableData04(chassisRecordType);
        initPricingTableData05(detailRecordType);
        initPricingTableData06(detailRecordType);
        initPricingTableData07(detailRecordType);
        initPricingTableData08(detailRecordType);
        initPricingTableData09(detailRecordType);
        initPricingTableSubmitTest(chassisRecordType, detailRecordType);

        
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

        List<Detail__c> details = new List<Detail__c>();
        // 筐体
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='Test Detail Name 1',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='特高',
            MinorClassificationCode__c='04',
            MinorClassificationName__c='特高監視盤',
            CategoryCode__c='',
            CategoryName__c='',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='TestChassis Name1',
            Name2__c='TestChassis Name2',
            Name3__c='TestChassis Name3',
            Name4__c='TestChassis Name4',
            Name5__c='TestChassis Name5',
            Name6__c='TestChassis Name6',
            Name7__c='',
            Name8__c='',
            Name9__c='',
            Name10__c='TestChassis Name10',
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
        PricingTable__c prcRecord = [SELECT Id, UniqueKey__c FROM PricingTable__c WHERE MajorClassificationName__c='共通機器' AND Name1__c='耐雷トランス' LIMIT 1];
        details.add(new Detail__c(
            Device__c=device1.Id,
            PricingTable__c=null,
            Name='耐雷トランス',
            Note__c='Test Detail Note',
            MajorClassificationCode__c='21',
            MajorClassificationName__c='共通機器',
            MinorClassificationCode__c='04',
            MinorClassificationName__c='特高監視盤',
            CategoryCode__c='',
            CategoryName__c='',
            detailedStatementText__c='Test Detail Statement',
            Name1__c='耐雷トランス',
            Name2__c='Test Detail Name 2',
            Name3__c='Test Detail Name 3',
            Name4__c='Test Detail Name 4',
            Name5__c='Test Detail Name 5',
            Name6__c='Test Detail Name 6',
            Name7__c='Test Detail Name 7',
            Name8__c='Test Detail Name 8',
            Name9__c='Test Detail Name 9',
            PricingTableUniqueKey__c= prcRecord.UniqueKey__c,
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
        insert details;
    }    
    
    // 変成機器：低圧
    static void initPricingTableData01(RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        List<String> name1List = new List<String>{'計器用変流器', '零相変流器+地絡過電流継電器'};
        List<String> name2List = new List<String>{'CT', 'ZCT+51G'};
        List<String> name3List = new List<String>{'一次電流1,000A', '低圧'};
        List<Decimal> priceList = new List<Decimal>{9800000, 11100000, 13200000, 16100000, 20100000};
        Integer recNo = 0;
        for(Integer i=0; i<name2List.size(); i++){
            pricingTableList.add(new PricingTable__c(
                RecordTypeId=detailRecordType.Id
                , BU__c='S'
                , RECNo__c=++recNo
                , MajorClassificationName__c='共通機器'
                , MinorClassificationName__c=null
                , CategoryName__c='明細'
                , DisplayName__c='変成機器：低圧'
                , Name1__c= name1List.get(i)
                , Name2__c= name2List.get(i)
                , Name3__c= name3List.get(i)
                , Name4__c= '22,000V'
                , Name5__c= '6,600V'
                , Name6__c= '特高TR油入'
                , Name10__c= '特高TR油入'
                , WC__c=null
                , Price__c=999999
                , Note__c=''
            ));
        }
        insert pricingTableList;
    }

    // ヒューズ付負荷開閉器（LBS)
    static void initPricingTableData02(RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        List<String> name3List = new List<String>{'60A以下', '100A', '200A'};
        List<String> name4List = new List<String>{'ﾌｯｸ操作', '遠方操作'};
        Integer recNo = 0;
        for(Integer i=0; i<name3List.size(); i++){
            for(Integer k=0; k<name4List.size(); k++){
                pricingTableList.add(new PricingTable__c(
                    RecordTypeId=detailRecordType.Id
                    , BU__c='S'
                    , RECNo__c=++recNo
                    , MajorClassificationName__c='共通機器'
                    , MinorClassificationName__c=null
                    , CategoryName__c='明細'
                    , DisplayName__c='ヒューズ付負荷開閉器（LBS)'
                    , Name1__c= 'ヒューズ付負荷開閉器'
                    , Name2__c= 'LBS'
                    , Name3__c= name3List.get(i)
                    , Name4__c= name4List.get(k)
                    , Name5__c= '6,600V'
                    , Name6__c= '特高TR油入'
                    , Name10__c= '特高TR油入'
                    , WC__c=null
                    , Price__c= (i==0?null:999999)
                    , Note__c=''
                ));
            }
        }
        insert pricingTableList;
    }

    // 変圧器収納盤(高圧)
    static void initPricingTableData03(RecordType chassisRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        List<String> searchOption = new List<String>{'屋内', '屋外', '屋内FF', '屋内FF'};

        Integer recNo = 0;
        for(Integer i=0; i<searchOption.size(); i++){
            pricingTableList.add(new PricingTable__c(
                RecordTypeId=chassisRecordType.Id
                , BU__c='S'
                , RECNo__c=++recNo
                , MajorClassificationName__c='変圧器'
                , MinorClassificationName__c='変圧器収納盤'
                , CategoryName__c='明細'
                , DisplayName__c='変圧器収納盤(高圧)'
                , Name1__c= '変圧器収納盤(高圧)'
                , Name2__c= searchOption.get(i)
                , Name3__c= 'Test Detail Name 3'
                , Name4__c= 'Test Detail Name 4'
                , Name5__c= '6,600V'
                , Name6__c= '特高TR油入'
                , Name10__c= '特高TR油入'
                , WC__c=null
                , Price__c= 999999
                , Note__c=''
            ));
        }
        insert pricingTableList;
    }

    // 変圧器収納盤(低圧)
    static void initPricingTableData04(RecordType chassisRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        List<String> searchOption = new List<String>{'屋内', '屋外', '屋内FF', '屋内FF'};

        Integer recNo = 0;
        for(Integer i=0; i<searchOption.size(); i++){
            pricingTableList.add(new PricingTable__c(
                RecordTypeId=chassisRecordType.Id
                , BU__c='S'
                , RECNo__c=++recNo
                , MajorClassificationName__c='変圧器'
                , MinorClassificationName__c='変圧器収納盤'
                , CategoryName__c='明細'
                , DisplayName__c='変圧器収納盤(低圧)'
                , Name1__c= '変圧器収納盤(低圧)'
                , Name2__c= searchOption.get(i)
                , Name3__c= 'Test Detail Name 3'
                , Name4__c= 'Test Detail Name 4'
                , Name5__c= '6,600V'
                , Name6__c= '特高TR油入'
                , Name10__c= '特高TR油入'
                , WC__c=null
                , Price__c= 999999
                , Note__c=''
            ));
        }
        insert pricingTableList;
    }

    // 接地トランス(GTR)
    static void initPricingTableData05(RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        Integer recNo = 0;
        pricingTableList.add(new PricingTable__c(
                RecordTypeId=detailRecordType.Id
                , BU__c='S'
                , RECNo__c=++recNo
                , MajorClassificationName__c='共通機器'
                , MinorClassificationName__c=null
                , CategoryName__c='明細'
                , DisplayName__c='接地トランス(GTR)'
                , Name1__c= '接地トランス'
                , Name2__c= 'GTR'
                , Name3__c= 'Test Detail Name 3'
                , Name4__c= 'Test Detail Name 4'
                , Name5__c= '6,600V'
                , Name6__c= '特高TR油入'
                , Name10__c= '特高TR油入'
                , WC__c=null
                , Price__c= 999999
                , Note__c=''));
        insert pricingTableList;
    }

    // 中性点付接地トランス(NGR)
    static void initPricingTableData06(RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        Integer recNo = 0;
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id
            , BU__c='S'
            , RECNo__c=++recNo
            , MajorClassificationName__c='共通機器'
            , MinorClassificationName__c=null
            , CategoryName__c='明細'
            , DisplayName__c='中性点付接地トランス(NGR)'
            , Name1__c= '中性点付接地トランス'
            , Name2__c= 'NGR'
            , Name3__c= 'Test Detail Name 3'
            , Name4__c= 'Test Detail Name 4'
            , Name5__c= '6,600V'
            , Name6__c= '特高TR油入'
            , Name10__c= '特高TR油入'
            , WC__c=null
            , Price__c= 999999
            , Note__c=''
        ));
        insert pricingTableList;
    }

    // 照明用・建築付帯用トランス
    static void initPricingTableData07(RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        Integer recNo = 0;
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id
            , BU__c='S'
            , RECNo__c=++recNo
            , MajorClassificationName__c='共通機器'
            , MinorClassificationName__c=null
            , CategoryName__c='明細'
            , DisplayName__c='照明用・建築付帯用トランス'
            , Name1__c= '照明用・建築付帯用トランス'
            , Name2__c= 'Test Detail Name 2'
            , Name3__c= 'Test Detail Name 3'
            , Name4__c= '単相'
            , Name5__c= '6,600V'
            , Name6__c= '特高TR油入'
            , Name10__c= '特高TR油入'
            , WC__c=null
            , Price__c= 999999
            , Note__c=''
        ));
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id
            , BU__c='S'
            , RECNo__c=++recNo
            , MajorClassificationName__c='共通機器'
            , MinorClassificationName__c=null
            , CategoryName__c='明細'
            , DisplayName__c='照明用・建築付帯用トランス'
            , Name1__c= '照明用・建築付帯用トランス'
            , Name2__c= 'Test Detail Name 2'
            , Name3__c= 'Test Detail Name 3'
            , Name4__c= '三相'
            , Name5__c= '6,600V'
            , Name6__c= '特高TR油入'
            , Name10__c= '特高TR油入'
            , WC__c=null
            , Price__c= null
            , Note__c=''
        ));
        insert pricingTableList;
    }

    // 耐雷トランス
    static void initPricingTableData08(RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        Integer recNo = 0;
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id
            , BU__c='S'
            , RECNo__c=++recNo
            , MajorClassificationName__c='共通機器'
            , MinorClassificationName__c=null
            , CategoryName__c='明細'
            , DisplayName__c='耐雷トランス'
            , Name1__c= '耐雷トランス'
            , Name2__c= 'Test Detail Name 2'
            , Name3__c= 'Test Detail Name 3'
            , Name4__c= '単相'
            , Name5__c= '6,600V'
            , Name6__c= '特高TR油入'
            , Name10__c= '特高TR油入'
            , WC__c=null
            , Price__c= 999999
            , Note__c=''
        ));
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id
            , BU__c='S'
            , RECNo__c=++recNo
            , MajorClassificationName__c='共通機器'
            , MinorClassificationName__c=null
            , CategoryName__c='明細'
            , DisplayName__c='耐雷トランス'
            , Name1__c= '耐雷トランス'
            , Name2__c= 'Test Detail Name 2'
            , Name3__c= 'Test Detail Name 3'
            , Name4__c= '三相'
            , Name5__c= '6,600V'
            , Name6__c= '特高TR油入'
            , Name10__c= '特高TR油入'
            , WC__c=null
            , Price__c= null
            , Note__c=''
        ));
        insert pricingTableList;
    }

    // 高圧盤内照明・電源用トランス
    static void initPricingTableData09(RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        Integer recNo = 0;
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id
            , BU__c='S'
            , RECNo__c=++recNo
            , MajorClassificationName__c='共通機器'
            , MinorClassificationName__c=null
            , CategoryName__c='明細'
            , DisplayName__c='耐雷トランス'
            , Name1__c= '高圧盤内照明・電源用トランス'
            , Name2__c= 'Test Detail Name 2'
            , Name3__c= 'Test Detail Name 3'
            , Name4__c= '単相2線'
            , Name5__c= '6,600V'
            , Name6__c= '特高TR油入'
            , Name10__c= '特高TR油入'
            , WC__c=null
            , Price__c= 999999
            , Note__c=''
        ));
        insert pricingTableList;
    }

    // 登録するテスト
    static void initPricingTableSubmitTest(RecordType chassisRecordType, RecordType detailRecordType) {
        List<PricingTable__c> pricingTableList = new List<PricingTable__c>();
        Integer recNo = 0;
        pricingTableList.add(new PricingTable__c(
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
        
        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='TestDetail MajorClassificationName__c',
            MajorClassificationCode__c='01',
            MinorClassificationName__c='TestDetail MinorClassificationName__c',
            MinorClassificationCode__c='01',
            CategoryName__c='明細',
            CategoryCode__c='01',
            DisplayName__c='明細',
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

        pricingTableList.add(new PricingTable__c(
            RecordTypeId=detailRecordType.Id,
            BU__c='S',
            RECNo__c=++recNo,
            MajorClassificationName__c='高圧受配電盤',
            MinorClassificationName__c=null,
            CategoryName__c='明細',
            DisplayName__c='',
            Name1__c='屋外用高圧交流ガス負荷開閉器',
            Name2__c='detailName2_1',
            Name3__c=null,
            Name4__c=null,
            Name5__c=null,
            Name6__c=null,
            Name10__c=null,
            WC__c=null,
            Price__c=999999,
            Note__c=''
        ));

        insert pricingTableList;
    }
}