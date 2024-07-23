Sub 肉鸽()
	
    TracePrint "肉鸽普通"
    If 肉鸽小队 = 0 Then 
        肉鸽队员 = Array("棘刺", "安赛尔", "梓兰")	
        招募棘刺 = 0
    ElseIf 肉鸽小队 = 3 Then
        肉鸽队员 = Array("令", "月见夜", "安赛尔")	
        招募棘刺 = -1
    End If
	
    //	已编队员 = 2
    Call 肉鸽开局()
    大锁 = false
    喉舌 = false
    不花钱=False
    到达层数=0
    点击 575, 1804
    Delay 1000
    肉鸽编队 
    Do
        KeepCapture 
        If 判断(肉鸽界面) = true Then 
            If 到达层数 = 5 Then 
                Delay 1000
            End If 
            节点类型 = 肉鸽选路()
            TracePrint 节点类型
            If 节点类型 = 0 or 节点类型 = 1 or 节点类型 = 3 Then 
                If 节点类型 = 1 And 肉鸽小队 = 2 Then 
                    肉鸽战斗结果 = False
                    肉鸽放弃
                Else 
                    肉鸽战斗结果 = 肉鸽战斗()
                End If
                
            ElseIf 节点类型 = 4 or 节点类型 = 2 Then
                肉鸽战斗结果= 肉鸽非战斗() 
            ElseIf 节点类型 = 5 Then
                肉鸽商店 
            ElseIf 节点类型 = -1 Then
                肉鸽战斗结果 = false
                肉鸽放弃
            End If
        ElseIf 判断(跳过) = true Then
            等待 跳过, 1000, 5, true
            等待 跳过确认, 1000, 5, true
            Delay 1000
        ElseIf 判断(凋零残响) = true Then
            肉鸽战斗结果 = false
        ElseIf 判断(肉鸽钟) = true Then
            点击 422, 1259
            Delay 2000
        End If
        Delay 500
        
    Loop Until 肉鸽战斗结果 = False 
    ShowMessage "失败返回"
    肉鸽结果
End Sub


Sub 肉鸽开局()
    ShowMessage "开局"
    TracePrint "肉鸽开局"
    Rem 开局
    TracePrint 肉鸽小队
    等待 开始探索, 1000, 5, False
    If 肉鸽小队 = 0 or 肉鸽小队 = 2 or 肉鸽小队=3 Then 
    
        Dim 第二招募=array(283,835,"283|835|9F967F,372|419|FFFFFF,465|1099|3D3D3D")

        ShowMessage "已进入"&局数&"次肉鸽,进入"&进商店次数&"次商店,遇到"&存钱次数&"次可以存钱,存了"&存钱数&"源石锭,耗时"&(TickCount()-tt)\60000 &"分钟"
        TracePrint "已进入"&局数&"次肉鸽,进入"&进商店次数&"次商店,遇到"&存钱次数&"次可以存钱,存了"&存钱数&"源石锭,耗时"&(TickCount()-tt)\60000 &"分钟"
        Do
            KeepCapture 
            If 判断(开始探索) = true Then 
                Tap 51, 1429
                delay 50
                Tap 开始探索(0), 开始探索(1)
			
            ElseIf 判断(选择分队) = true Then
                //			TracePrint "112"
                If 肉鸽分队 < 5 Then 
                    点击 195,94+426*肉鸽分队
                    Delay 600
                    点击 195,94 + 426 * 肉鸽分队
                    Delay 600
                ElseIf 肉鸽分队 > 4 Then
                    For 3
                        Swipe  356, 1568,420, 634, 50
                        Delay 100
                    Next 
                    Delay 1400
                    点击 195,70+426*(肉鸽分队-5)
                    Delay 600
                    点击 195, 70 + 426 * (肉鸽分队-5)
                    Delay 600
                End If
			

            elseIf 判断(选择支援) = true Then 
            
           
                For i = 0 To 2
                    KeepCapture 
                    FindColor 289,357+426*i,310,705+426*i,"362AC8",0,0.9,intX,intY
                    If intX = -1 And intY = -1 Then
                        点击 203, 536 + 426 * i
                        Delay 800
                        点击 203, 536 + 426 * i
                        Delay 800
                        Exit For
                    End If
                Next
            ElseIf 判断(选择招募组合) = true Then
                Tap 选择招募组合(0), 选择招募组合(1)
                Delay 50
            ElseIf 判断(肉鸽先锋招募) = true Then
            ElseIf 判断(初始招募) = true Then
                If 肉鸽小队 = 0 or 肉鸽小队 = 2 Then 
                    Tap 初始招募(0), 初始招募(1)
                    Call 肉鸽招募(肉鸽初始队员(0))
                    Delay 1000
                    tap 260, 915
                    Call 肉鸽招募(肉鸽初始队员(1))
        	
                ElseIf 肉鸽小队 = 3 Then
                    tap 260, 915
                    Call 肉鸽招募(肉鸽初始队员(0))
                    Delay 1000
                    Tap 初始招募(0), 初始招募(1)
                    Call 肉鸽招募(肉鸽初始队员(1))        	
                End If
                Delay 1000
                tap 272,1394
                Call 肉鸽招募(肉鸽初始队员(2))
                Delay 300
                tap 575, 1804
                Delay 1000
                局数=局数+1
                Exit Do
            End If
            Delay 30
        Loop 
	
    ElseIf 肉鸽小队 = 1 Then
        TracePrint "月度小队"
        点击 41,1050'月度小队
        Delay 800
        点击 开始探索(0), 开始探索(1)
        Delay 1000
        等待 小队干员, 1000, 5, true
        Delay 1000
        点击 小队干员(0), 小队干员(1)
        Delay 1000
        KeepCapture 
        If  肉鸽分队=1 Then 
            点击 后勤分队(0), 后勤分队(1)
            Delay 1000
            点击 后勤分队(0), 后勤分队(1)
            Delay 1000
        Else 
            点击 选择分队(0), 选择分队(1)
            Delay 1000
            点击 选择分队(0), 选择分队(1)
            Delay 1000
        End If
        Delay 3000
        等待 跳过, 1000, 5, true
        等待 跳过确认, 1000, 5, true
        Delay 1000
        
    End If
	
	
End Sub


Function 肉鸽选路()
    TracePrint "肉鸽选路"
    Dim arr(),arr1()
    Dim 地图名
    Dim 有路=false	
    Delay 1000
    KeepCapture 
    For j = 1 To 0 Step -1
        If 有路 = false Then
            For i = 0 To 6
                arr(i)=CmpColor(818-102*i, 587+664*j, "054EDE|066AC7|C2C00B|0F98D0|D09404|789512", 0.95)'BOSS|紧急|不期而遇|战斗|安全的角落|商店
                If arr(i) > -1 Then 
                    TracePrint i,j
                    有路 = true
                    选路位置=j                    			
                End If
            Next
        End If	
    Next
    TracePrint "选路位置",选路位置
    If 选路位置 = 0 Then 
        到达层数 = 到达层数 + 1
        TracePrint 到达层数
    End If
    arr1 = Clone(arr)
    zm.ArraySort arr, true
    zm.TracePrint arr
    zm.TracePrint arr1
    肉鸽选路 = arr(0)

    ShowMessage "到达第" & 到达层数 & "层,选择节点" & 节点(arr(0))
    Delay 50
    For i = 0 To 6   
        If arr1(i) = arr(0) Then 
            点击 838 - 102 * i, 584 + 664 * 选路位置
            Delay 800
            Exit For
        End If        
    Next    
End Function

Sub 肉鸽商店()
    Dim 商品1,商品2,商品排序
    dim 商品=array(0,0,0,0,0,0,0,0)
    等待 肉鸽商店进入, 1000, 5, true
    Delay 2500
    //    If 不花钱 = false Then 
    Dim item
    商品1 = zm.OcrBaiDuAll(875, 675, 916, 1816)
    Delay 1000
    商品2 = zm.OcrBaiDuAll(565, 652, 608, 1729)
    Dim a1=商品1["words_result"]
    Dim a2=商品2["words_result"]
    zm.TracePrint a1, a2
    For i = 0 To UBOUND(a1)
        item=a1(i)
        If isin(肉鸽商品评分, item["words"]) = true Then 
            商品(i)=肉鸽商品评分[item["words"]]
        End If
    Next
    For i = 0 To UBOUND(a2)
        item=a2(i)
        If isin(肉鸽商品评分, item["words"]) = true Then 
            商品(i+4)=肉鸽商品评分[item["words"]]
        End If
    Next
    zm.TracePrint 商品
    进商店次数 = 进商店次数 + 1
    Dim 商品生效
    SnapShot "/sdcard/Pictures/Screenshots/商店/"& Time() &".png"
	
    If ReadUIConfig("不存钱") = false Then 
        KeepCapture 
        If 判断(存钱按钮) = true Then 
            存钱次数=存钱次数+1
            ShowMessage "我tm存爆"
            Call 存钱()
            Delay 2000
        End If
    End If
    KeepCapture
    //    If 招募棘刺 = 1 and 精二棘刺=true Then 
    //        EndScript
    //    End If
    商品排序 = Clone(商品)
    dim 商品位置
    zm.ArraySort 商品排序, true		
    For i = 0 To 7
        If (商品排序(i) > 0 and 不花钱=false) or (商品排序(i)>=96 and 不花钱=true) Then 
            商品位置 = zm.ArraySearch(商品, 商品排序(i))
            KeepCapture 
            If CmpColor(671 - 317 * (商品位置 \ 4), 817 + 309 * (商品位置 mod 4), "A9CD02", 0.7) > -1 or CmpColor(671 - 317 * (商品位置 \ 4), 789 + 309 * (商品位置 mod 4), "A9CD02", 0.7) > -1 Then 
                点击 762 - 300 * (商品位置 \ 4), 756 + 300 * (商品位置 mod 4)
                Delay 2000
                KeepCapture
                If 判断(没有生效)=true Then 
                    点击 333,944'算了
                    Delay 1500
                Else
                    If 商品排序(i) >= 109 Then 
                        不花钱=true
                    End If
                
                    点击 340, 1447		
                    Delay 2000
                    KeepCapture 
                    If 判断(肉鸽招募界面) = true Then 
                        Call 肉鸽招募(null)
                    End If
                End If
            End If
        End If       	
    Next
    //    End If
    
    Delay 500
    点击 263, 1763
    Delay 1000
    点击 263, 1763
    Delay 5000
    
    
End Sub

Function 肉鸽战斗()
    Dim 进入=array(肉鸽战斗进入,肉鸽紧急作战进入,肉鸽boss作战进入)	
    等待(进入, 1000, 3, false)     
    Dim 地图名=识别肉鸽地图()
    Dim boss收藏,收藏1,ix,iy
    If IsNull(地图名) = true Then 
        SnapShot "/sdcard/Pictures/Screenshots/战斗/" & Time() & ".png"
        //        zm.KeyPressScreenShot 
        If 第三层boss = true Then 
            If (大锁开局 = false and 喉舌开局 = false) or (大锁开局 = true and 大锁 = true) or (喉舌开局 = true and 喉舌 = true) Then 
                EndScript
            End If        	
        End If
        肉鸽战斗 = False
        肉鸽放弃 
        Exit Function

    End If
    If 到达层数 = 4 and 攻速开局 = true Then 
        If 不花钱 = false Then 
            肉鸽战斗 = False
            肉鸽放弃
            Exit Function    		
        End If
    End If
    ShowMessage "开始作战,地图:" & 地图名
    地图名=地图名&"-"&肉鸽小队
    点击 354, 1726
    
    If 到达层数 >= 5 and 第五层暂停=true Then 
        UI.NewLayout ("第五层确认")
        UI.AddTextView "第五层确认", "文本1", "点继续脚本继续打,点退出自己继续打"
        ui.Show("第五层确认")
    End If
    Delay 2000
    等待 肉鸽开始行动, 1000, 2, false
    zm.TracePrint 肉鸽队员
    ReleaseCapture 
    Dim 已编,上限
    Do
    	
        已编=CInt(SmartOcr(35, 257, 69, 287))
        上限=CInt(SmartOcr(40, 299, 67, 340))
        TracePrint 已编&"/"&上限
        If 已编 < 10 and 上限 > 13 Then 
            已编=CInt(SmartOcr(35, 266, 69, 304))
            上限=CInt(SmartOcr(40, 316, 67, 352))
        End If
    Loop Until (已编 <= 上限 and 已编 >= 上限 - 6 and 上限 <= 13)
    If 已编 = 上限 and 到达层数>=4 Then 
        If UBOUND(肉鸽队员) >= 已编 Then 
            If zm.ArraySearch(肉鸽队员, "梓兰") > -1 Then 
                肉鸽下干员 (zm.ArraySearch(肉鸽队员, "梓兰"))
                已编 = 已编 - 1
                zm.TracePrint 肉鸽队员
                TracePrint 已编
            ElseIf zm.ArraySearch(肉鸽队员, "史都华德") > -1 and zm.ArraySearch(肉鸽队员, "艾雅法拉") > -1 Then
                肉鸽下干员 (zm.ArraySearch(肉鸽队员, "史都华德"))
                已编 = 已编 - 1
                zm.TracePrint 肉鸽队员
                TracePrint 已编
            ElseIf zm.ArraySearch(肉鸽队员, "芬") > -1 and zm.ArraySearch(肉鸽队员, "桃金娘") > -1 Then
    		
                肉鸽下干员 (zm.ArraySearch(肉鸽队员, "芬"))
                已编 = 已编 - 1
                zm.TracePrint 肉鸽队员
                TracePrint 已编
            ElseIf zm.ArraySearch(肉鸽队员, "芙蓉") > -1 and zm.ArraySearch(肉鸽队员, "凯尔希") > -1 Then
    		
                肉鸽下干员 (zm.ArraySearch(肉鸽队员, "芙蓉"))
                已编 = 已编 - 1
                zm.TracePrint 肉鸽队员
                TracePrint 已编
            ElseIf zm.ArraySearch(肉鸽队员, "斑点") > -1 and zm.ArraySearch(肉鸽队员, "塞雷娅") > -1 Then
    		
                肉鸽下干员 (zm.ArraySearch(肉鸽队员, "斑点"))
                已编 = 已编 - 1
                zm.TracePrint 肉鸽队员
                TracePrint 已编
            ElseIf zm.ArraySearch(肉鸽队员, "红") > -1 and zm.ArraySearch(肉鸽队员, "银灰") > -1 and zm.ArraySearch(肉鸽队员, "史尔特尔") > -1 Then
    		
                肉鸽下干员 (zm.ArraySearch(肉鸽队员, "红"))
                已编 = 已编 - 1
                zm.TracePrint 肉鸽队员
                TracePrint 已编
            End If
    		
        End If
    End If
    If  已编<上限  Then     
        For 上限-已编        
            If UBOUND(肉鸽队员) >= 已编 Then 
                肉鸽上干员 (已编)
                已编 = 已编+ 1
                等待 肉鸽开始行动, 1000, 2, false
            End If       
        Next
    End If
    zm.TracePrint 肉鸽队员
    zm.TracePrint 队员技能
    For i = 0 To 已编-1 	
        If  isin(队员技能, 肉鸽队员(i))=true Then 
            肉鸽点技能(i,队员技能[肉鸽队员(i)])
        End If
    Next
    Call prts(地图名, false)
    Delay 5000
    KeepCapture 
    If 判断(联系中断) = true or 判断(凋零残响) or 判断(肉鸽钟)=true Then
        点击 联系中断(0), 联系中断(1)
        Delay 2000
        肉鸽战斗 = False
        Exit function
    End If
    ShowMessage "等待成功通过"
    等待 成功通过, 2500, 6, false
	
    点击 200, 1650
    肉鸽战斗 = True
    等待(战斗奖励, 1000, 5, false)
    dim n=0	
    Do
        KeepCapture 
        FindMultiColor (539,133,540,1807,"9B9B9B-101010","-144|111|DDDDDD,-128|-60|DDDDDD",8,0.9,intX,intY)		
        If CmpColor(279, 113, "58723A", 0.95) > -1 Then
            TracePrint "源石锭"
            点击 279, 113
            Delay 2000
        elseIf CmpColor(279, 113, "216A9D", 0.95) > -1 Then
            TracePrint "收藏品"
            FindMultiColor 288, 83, 296, 106, "1E689B", "212|204|DDDDDD,415|243|0C4CBF,431|161|477BCB,388|109|FCFCFF", 0, 0.9, ix, iy
            If ix > -1 Then 
                TracePrint "金杯"
                不花钱 = true
            Else 
                FindMultiColor 288, 83, 296, 106, "1E689B","206|192|DDDDDD,468|227|0059BB,361|104|5476F0,380|126|0091DB", 0, 0.9, ix, iy
                If ix > -1 Then 
                    TracePrint "戒律"
                    不花钱 = true
                Else 
                    TracePrint "无"
                End If
            End If
            点击 279, 113
            Delay 2000
        ElseIf CmpColor(279, 113, "296379", 0.95) > -1 Then
            TracePrint "未知剧目"
            点击 279, 113
            Delay 500
            KeepCapture
            If CmpColor(198,326, "1E3D51", 0.9) > -1 Then 
                点击 210,343
            End If            
            Delay 1500
            点击 91, 966
            Delay 1200
        ElseIf CmpColor(279, 113, "9F967F", 0.9) > -1 Then
            TracePrint "招募"
            点击 279, 113  
            Call 肉鸽招募(Null)
        ElseIf 判断(招募选择) = True Then
            If 判断(选择第二近卫招募) = true or 判断(选择第二狙击招募)=true Then 
                点击 332, 1094
            Else 
                点击 招募选择(0), 招募选择(1)
            End If
            	
            Call 肉鸽招募(Null)
        ElseIf CmpColor(279, 113, "6F6F6F", 0.9) > -1 Then
            TracePrint "支援，收藏品"
            点击 279, 113
            Delay 1000
            KeepCapture 
            FindMultiColor 342, 340, 343, 1551, "1E689B", "-33|268|1E689B", 0, 0.9, intX, intY
            If intX > -1 Then 
                SnapShot "/sdcard/Pictures/Screenshots/boss奖励/"& Time() &".png"
                FindMultiColor 347, 56, 352, 1864, "1E689B", "212|204|DDDDDD,415|243|0C4CBF,431|161|477BCB,388|109|FCFCFF", 0, 0.9, ix, iy
                If ix > -1 Then 
                    TracePrint "金杯",ix,iy
                    不花钱 = true
                    点击 ix - 10, iy + 100
                Else 
                    FindMultiColor 347, 56, 353, 1864, "1E689B","206|192|DDDDDD,468|227|0059BB,361|104|5476F0,380|126|0091DB", 0, 0.9, ix, iy
                    If ix > -1 Then 
                        TracePrint "戒律",ix,iy
                        不花钱 = true
                        点击 ix - 10, iy + 100
                    Else 
                        TracePrint "无"
                        点击 intX, intY
                    End If
                End If     			
       			
                Delay 600
            End If
        elseIf intX >-1 and n > 30 Then
            Tap IntX, IntY
            Delay 100
            Tap IntX-290, IntY+100
            Exit Do
        ElseIf 判断(奖励全部领完) = true Then
            点击 奖励全部领完(0), 奖励全部领完(1)
            Delay 1000
            Exit Do
        ElseIf 判断(肉鸽招募界面) = true Then
            Call 肉鸽招募(null)
        ElseIf 判断(成功通过) = true Then
            点击 200, 1650
        ElseIf 判断(凋零残响) = true Then
            肉鸽战斗 = False
            Exit Do 
        End If
        n=n+1
        Delay 1000
    Loop
	
End Function

Sub 肉鸽招募(a)
    TracePrint "肉鸽招募",a
    Dim 干员=a
    Dim 招募到=false
    Dim arr1(),arr
    dim 被招募干员 
    Dim i
    等待 肉鸽招募界面, 600,5, false
    Delay 300
    If IsNull(干员) = true Then 
        KeepCapture 
        If CmpColor(935, 686, "C4C4C4", 0.9) = -1 Then 
            Call TURING.Lib_Load(GetTempDir() & "肉鸽干员"&肉鸽小队&".lib")
            If 招募到 = False Then 
                For 5               
                    For i = 0 To 7
                        Call 肉鸽切割(i)
                        ' 识别字库路径可自行更换！！！
                        被招募干员 = TURING.OCR(80)
                        TracePrint i,被招募干员
                        If 被招募干员 <>null and 被招募干员 <> "预备干员" and 被招募干员 <> "安赛尔" Then 
                            点击 862 - 205 * (i mod 4), 905 + 585 * (i \ 4)                          	
                            If zm.ArraySearch(肉鸽队员, 被招募干员) =-1 Then 
                                zm.ArrayInsert(肉鸽队员, 被招募干员)
                            ElseIf 被招募干员 = "棘刺" Then
                                招募棘刺 =1
                            End If	
                            Delay 300
                            招募到=true
                            Exit For
                        End If
                    Next
                    If 招募到 = true Then 
                        Exit For
                    End If
                    KeepCapture 
                    If CmpColor(922, 1015, "64542A", 0.9) > -1 or cmpcolor(222,1704,"E0E0E0",0.9)>-1 Then 
                        TracePrint "全是三星"
                        Exit For
                    End If
                    Call 肉鸽干员翻页()
                    Delay 500
                Next
        	
            End If
        
            If 招募到 = False Then 
                Call TURING.Lib_Load(GetTempDir() & "肉鸽干员"&肉鸽小队&".lib")
                For 5
               
                    For i = 0 To 7
                        Call 肉鸽切割(i)
                        ' 识别字库路径可自行更换！！！
                        被招募干员 = TURING.OCR(80)
                        TracePrint 被招募干员,i
                        If 被招募干员 = "预备干员" Then 
                            点击 862 - 205 * (i mod 4), 905 + 585 * (i \ 4)  
                            //                            If zm.ArraySearch(肉鸽队员, 被招募干员) =-1 Then 
                            //                                zm.ArrayInsert(肉鸽队员, 被招募干员)
                            //                            End If	
                            Delay 300
                            招募到=true
                            Exit For
                        End If
                    Next
                    If 招募到 = true Then 
                        Exit For
                    End If
                    TouchDown 534, 616,1    
                    Delay 200
                    TouchMove 534,1903, 1, 200
                    Delay 100
                    TouchMove 534,1903, 1, 200     
                    Delay 400
                    TouchUp 1
                    Delay 200
                    Delay 500
                Next
        	
            End If
        End if
		
    ElseIf IsNumeric(干员) = true Then
		
		
		 
        For i = 0 To 7
            点击 862 - 205 * (i mod 4), 905 + 585 * (i \ 4)
            Delay 300
            KeepCapture
            If CInt(SmartOcr(673, 400, 692, 413)) >= 干员 Then 
                ShowMessage "招募阻挡数大于"&干员
                Exit for
            End If
        Next
		
    Else 
        TracePrint "招募",干员,肉鸽小队
        TracePrint TURING.Lib_Load(GetTempDir() & "肉鸽干员"&肉鸽小队&".lib",干员)
        
        For i = 0 To 7
            Call 肉鸽切割(i)
            
            ' 识别字库路径可自行更换！！！
            TracePrint TURING.OCR(80),i
            If TURING.OCR(80) = 干员 Then 
                点击 862 - 205 * (i mod 4),905 + 585 * (i \ 4)
                Delay 300
                招募到=true
                Exit For
            End If
        Next
        If 招募到 = False Then 
            For 5
                Call 肉鸽干员翻页()
                For i = 0 To 7
                    Call 肉鸽切割(i)
                    ' 识别字库路径可自行更换！！！
                    TracePrint TURING.OCR(80),i
                    If TURING.OCR(80)=干员 Then 
                        点击 862 - 205 * (i mod 4), 905 + 585 * (i \ 4)
                        Delay 300
                        招募到=true
                        Exit For
                    End If
                Next
                If 招募到 = true Then 
                    Exit For
                End If
            Next        	
        End If
        KeepCapture
        If 招募到 = false and CmpColor(1020,1584,"FDFDFD",0.9)>-1  Then 
            点击 1027, 1757
            Delay 500
            arr=array(1,干员)
            Call 编入支援干员(arr, 1)  
        End If
    End If
    Delay 1500
    KeepCapture 
    If 判断(招募助战) = true Then 
        点击 招募助战(0),招募助战(1)
    Else 
        点击 肉鸽招募界面(0), 肉鸽招募界面(1)	
    End If
    Delay 1000
    KeepCapture 
    If 判断(退出基建) = true Then
        点击 退出基建(0), 退出基建(1)
        Delay 800
    ElseIf CmpColor(1012, 1824, "00007D", 0.9) = -1 Then 
        点击 1017, 1848
        Delay 800
        点击 1017, 1848
        Delay 1500
    End If
    
End Sub