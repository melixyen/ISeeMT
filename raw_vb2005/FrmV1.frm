VERSION 5.00
Begin VB.Form FrmV1 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00000000&
   BorderStyle     =   0  '沒有框線
   Caption         =   "popup"
   ClientHeight    =   8160
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12000
   FillStyle       =   0  '實心
   Icon            =   "FrmV1.frx":0000
   LinkTopic       =   "FrmV1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   2  '自訂調色盤
   ScaleHeight     =   8160
   ScaleWidth      =   12000
   ShowInTaskbar   =   0   'False
   Begin VB.PictureBox Picture1 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00808080&
      BorderStyle     =   0  '沒有框線
      FillColor       =   &H00808080&
      FillStyle       =   0  '實心
      Height          =   7815
      Left            =   0
      ScaleHeight     =   7815
      ScaleWidth      =   11535
      TabIndex        =   0
      Top             =   0
      Width           =   11535
      Begin VB.Frame Frame2 
         Caption         =   "     Set Color or Auto"
         Height          =   7095
         Left            =   360
         TabIndex        =   1
         Top             =   360
         Width           =   8415
         Begin VB.ComboBox Combo4 
            Height          =   300
            ItemData        =   "FrmV1.frx":B08A
            Left            =   2160
            List            =   "FrmV1.frx":B0A0
            TabIndex        =   32
            Text            =   "Black"
            Top             =   3720
            Width           =   855
         End
         Begin VB.CommandButton Command33 
            Caption         =   "Cross Line"
            Height          =   375
            Left            =   240
            TabIndex        =   30
            ToolTipText     =   "If you use this, Pixel Width will set on Line with Line."
            Top             =   3720
            Width           =   975
         End
         Begin VB.CommandButton Command32 
            Caption         =   "Text3"
            Height          =   375
            Left            =   6480
            TabIndex        =   87
            Top             =   6600
            Width           =   735
         End
         Begin VB.CommandButton Command31 
            Caption         =   "Text2"
            Height          =   375
            Left            =   5760
            TabIndex        =   86
            Top             =   6600
            Width           =   735
         End
         Begin VB.CommandButton Command30 
            Caption         =   "Text1"
            Height          =   375
            Left            =   5040
            TabIndex        =   85
            Top             =   6600
            Width           =   735
         End
         Begin VB.ComboBox CbTxC 
            Height          =   300
            ItemData        =   "FrmV1.frx":B0CA
            Left            =   4200
            List            =   "FrmV1.frx":B0F2
            TabIndex        =   84
            Text            =   "255"
            ToolTipText     =   "You can key-in 0 to 255"
            Top             =   6600
            Width           =   735
         End
         Begin VB.ComboBox CbTxBK 
            Height          =   300
            ItemData        =   "FrmV1.frx":B12C
            Left            =   2760
            List            =   "FrmV1.frx":B154
            TabIndex        =   83
            Text            =   "0"
            ToolTipText     =   "You can key-in 0 to 255"
            Top             =   6600
            Width           =   735
         End
         Begin VB.CommandButton Command29 
            Caption         =   "AA"
            Height          =   300
            Left            =   7200
            TabIndex        =   37
            Top             =   3720
            Visible         =   0   'False
            Width           =   735
         End
         Begin VB.CommandButton Command28 
            Caption         =   "Med Stack"
            Height          =   375
            Left            =   5040
            TabIndex        =   42
            Top             =   4440
            Width           =   975
         End
         Begin VB.CommandButton Command26 
            Caption         =   "3-Bar"
            Height          =   375
            Index           =   1
            Left            =   6720
            TabIndex        =   58
            Top             =   5880
            Width           =   615
         End
         Begin VB.Timer Timer4 
            Enabled         =   0   'False
            Left            =   6120
            Top             =   5400
         End
         Begin VB.CommandButton Command26 
            Caption         =   "Full Back"
            Height          =   375
            Index           =   0
            Left            =   5760
            TabIndex        =   57
            Top             =   5880
            Width           =   855
         End
         Begin VB.Timer Timer3 
            Enabled         =   0   'False
            Interval        =   250
            Left            =   5160
            Top             =   5400
         End
         Begin VB.CommandButton Command25 
            Caption         =   "Circle"
            Height          =   375
            Left            =   5040
            TabIndex        =   56
            Top             =   5880
            Width           =   615
         End
         Begin VB.Timer Timer2 
            Enabled         =   0   'False
            Interval        =   250
            Left            =   4440
            Top             =   5400
         End
         Begin VB.CommandButton Command24 
            Caption         =   "Cube"
            Height          =   375
            Left            =   4320
            TabIndex        =   55
            Top             =   5880
            Width           =   615
         End
         Begin VB.CommandButton Command23 
            Caption         =   "Interval"
            Height          =   375
            Left            =   3480
            TabIndex        =   54
            Top             =   5880
            Width           =   735
         End
         Begin VB.CommandButton Command22 
            Caption         =   "Gray Wave"
            Height          =   375
            Left            =   2520
            TabIndex        =   53
            Top             =   5880
            Width           =   975
         End
         Begin VB.CheckBox Check1 
            Caption         =   "With # line"
            Height          =   255
            Left            =   1440
            TabIndex        =   16
            Top             =   2040
            Width           =   1335
         End
         Begin VB.ComboBox CbT1 
            Height          =   300
            ItemData        =   "FrmV1.frx":B18E
            Left            =   1440
            List            =   "FrmV1.frx":B1C2
            TabIndex        =   52
            Text            =   "250ms"
            Top             =   5880
            Width           =   975
         End
         Begin VB.CommandButton Command21 
            Caption         =   "Blue"
            Height          =   375
            Left            =   7200
            TabIndex        =   51
            Top             =   5160
            Width           =   975
         End
         Begin VB.CommandButton Command18 
            Caption         =   "Green"
            Height          =   375
            Left            =   6240
            TabIndex        =   50
            Top             =   5160
            Width           =   975
         End
         Begin VB.CommandButton Command15 
            Caption         =   "Red"
            Height          =   375
            Left            =   5280
            TabIndex        =   49
            Top             =   5160
            Width           =   975
         End
         Begin VB.TextBox TxCwY 
            Height          =   285
            Left            =   3360
            MaxLength       =   2
            TabIndex        =   40
            Text            =   "4"
            Top             =   4440
            Width           =   495
         End
         Begin VB.TextBox TxCwX 
            Height          =   285
            Left            =   2520
            MaxLength       =   2
            TabIndex        =   39
            Text            =   "4"
            Top             =   4440
            Width           =   495
         End
         Begin VB.CommandButton Command20 
            Caption         =   "Gray (204)"
            Height          =   375
            Left            =   4320
            TabIndex        =   48
            Top             =   5160
            Width           =   975
         End
         Begin VB.CommandButton Command19 
            Caption         =   "Gray (128)"
            Height          =   375
            Left            =   3360
            TabIndex        =   47
            Top             =   5160
            Width           =   975
         End
         Begin VB.CommandButton Command17 
            Caption         =   "Dark Stack"
            Height          =   375
            Left            =   7200
            TabIndex        =   44
            Top             =   4440
            Width           =   975
         End
         Begin VB.CommandButton Command16 
            Caption         =   "Light Stack"
            Height          =   375
            Left            =   4080
            TabIndex        =   41
            Top             =   4440
            Width           =   975
         End
         Begin VB.CommandButton Command14 
            Caption         =   "Color Wall"
            Height          =   375
            Left            =   7200
            TabIndex        =   36
            Top             =   3240
            Width           =   975
         End
         Begin VB.CommandButton Command13 
            Caption         =   "White"
            Height          =   375
            Left            =   2400
            TabIndex        =   46
            Top             =   5160
            Width           =   975
         End
         Begin VB.CommandButton Command12 
            Caption         =   "Black"
            Height          =   375
            Left            =   1440
            TabIndex        =   45
            Top             =   5160
            Width           =   975
         End
         Begin VB.ComboBox CbLW2 
            Height          =   300
            ItemData        =   "FrmV1.frx":B232
            Left            =   6000
            List            =   "FrmV1.frx":B284
            TabIndex        =   35
            Text            =   "1x"
            Top             =   3720
            Width           =   855
         End
         Begin VB.ComboBox CbLW1 
            Height          =   300
            ItemData        =   "FrmV1.frx":B310
            Left            =   6000
            List            =   "FrmV1.frx":B362
            TabIndex        =   33
            Text            =   "1x"
            Top             =   3360
            Width           =   855
         End
         Begin VB.ComboBox CbL2 
            Height          =   300
            ItemData        =   "FrmV1.frx":B3EE
            Left            =   4080
            List            =   "FrmV1.frx":B401
            TabIndex        =   34
            Text            =   "White"
            Top             =   3720
            Width           =   855
         End
         Begin VB.ComboBox CbL1 
            Height          =   300
            ItemData        =   "FrmV1.frx":B425
            Left            =   4080
            List            =   "FrmV1.frx":B438
            TabIndex        =   31
            Text            =   "Black"
            Top             =   3360
            Width           =   855
         End
         Begin VB.TextBox CM2RGB 
            Height          =   285
            Index           =   1
            Left            =   2520
            MaxLength       =   3
            TabIndex        =   4
            Text            =   "0"
            ToolTipText     =   "Green"
            Top             =   360
            Width           =   735
         End
         Begin VB.TextBox CM2RGB 
            Height          =   285
            Index           =   2
            Left            =   1680
            MaxLength       =   3
            TabIndex        =   3
            Text            =   "0"
            ToolTipText     =   "Red"
            Top             =   360
            Width           =   735
         End
         Begin VB.CommandButton CcGU 
            Caption         =   "_"
            Height          =   255
            Index           =   1
            Left            =   4800
            TabIndex        =   6
            Top             =   360
            Width           =   255
         End
         Begin VB.TextBox Text2 
            Height          =   285
            Left            =   7440
            MaxLength       =   3
            TabIndex        =   9
            Text            =   "1"
            Top             =   360
            Width           =   615
         End
         Begin VB.CommandButton CcGU 
            Caption         =   "+"
            Height          =   255
            Index           =   0
            Left            =   5760
            TabIndex        =   8
            Top             =   360
            Width           =   255
         End
         Begin VB.TextBox CM2Gray 
            Height          =   285
            Left            =   5040
            MaxLength       =   3
            TabIndex        =   7
            Top             =   360
            Width           =   735
         End
         Begin VB.TextBox CM2RGB 
            Height          =   285
            Index           =   0
            Left            =   3360
            MaxLength       =   3
            TabIndex        =   5
            Text            =   "0"
            ToolTipText     =   "Blue"
            Top             =   360
            Width           =   735
         End
         Begin VB.OptionButton Option2 
            Caption         =   "Color1 (R:G:B)"
            Height          =   255
            Left            =   120
            TabIndex        =   2
            Top             =   360
            Value           =   -1  'True
            Width           =   1455
         End
         Begin VB.CommandButton Command1 
            Caption         =   "White Back"
            Height          =   375
            Left            =   2880
            TabIndex        =   17
            Top             =   2040
            Width           =   975
         End
         Begin VB.CommandButton Command3 
            Caption         =   "Black Back"
            Height          =   375
            Left            =   3960
            TabIndex        =   18
            Top             =   2040
            Width           =   975
         End
         Begin VB.CommandButton Command4 
            Caption         =   "Red Back"
            Height          =   375
            Left            =   5040
            TabIndex        =   19
            Top             =   2040
            Width           =   975
         End
         Begin VB.CommandButton Command5 
            Caption         =   "Green Back"
            Height          =   375
            Left            =   6120
            TabIndex        =   20
            Top             =   2040
            Width           =   975
         End
         Begin VB.CommandButton Command6 
            Caption         =   "Blue Back"
            Height          =   375
            Left            =   7200
            TabIndex        =   21
            Top             =   2040
            Width           =   975
         End
         Begin VB.CommandButton Command7 
            Caption         =   "&Close"
            Height          =   375
            Left            =   7200
            TabIndex        =   15
            Top             =   1320
            Width           =   975
         End
         Begin VB.CommandButton Command8 
            Caption         =   "Cube"
            Height          =   375
            Left            =   1440
            TabIndex        =   38
            Top             =   4440
            Width           =   615
         End
         Begin VB.CommandButton Command9 
            Caption         =   "Color Table"
            Height          =   375
            Left            =   240
            TabIndex        =   22
            Top             =   2640
            Width           =   1455
         End
         Begin VB.OptionButton Option1 
            Caption         =   "Auto Color Show :"
            Height          =   255
            Left            =   120
            TabIndex        =   10
            Top             =   840
            Width           =   1695
         End
         Begin VB.Timer Timer1 
            Enabled         =   0   'False
            Interval        =   100
            Left            =   2760
            Top             =   5400
         End
         Begin VB.CommandButton Command2 
            Caption         =   "Show Setting on Monitor"
            Height          =   495
            Left            =   480
            TabIndex        =   14
            Top             =   1200
            Width           =   2415
         End
         Begin VB.ComboBox Combo1 
            Height          =   300
            ItemData        =   "FrmV1.frx":B45C
            Left            =   1920
            List            =   "FrmV1.frx":B46C
            TabIndex        =   11
            Text            =   "Gray"
            Top             =   840
            Width           =   855
         End
         Begin VB.TextBox Text1 
            Height          =   285
            Left            =   4080
            MaxLength       =   3
            TabIndex        =   12
            Text            =   "1"
            Top             =   840
            Width           =   615
         End
         Begin VB.TextBox Text3 
            Height          =   285
            Left            =   6120
            MaxLength       =   3
            TabIndex        =   13
            Text            =   "10"
            Top             =   840
            Width           =   495
         End
         Begin VB.ComboBox Combo2 
            Height          =   315
            ItemData        =   "FrmV1.frx":B488
            Left            =   2520
            List            =   "FrmV1.frx":B4A4
            TabIndex        =   23
            Text            =   "256"
            Top             =   2640
            Width           =   855
         End
         Begin VB.ComboBox CbR 
            Height          =   300
            ItemData        =   "FrmV1.frx":B4C8
            Left            =   5760
            List            =   "FrmV1.frx":B4D2
            TabIndex        =   25
            Text            =   "255"
            Top             =   2640
            Width           =   735
         End
         Begin VB.ComboBox CbG 
            Height          =   300
            ItemData        =   "FrmV1.frx":B4DE
            Left            =   6600
            List            =   "FrmV1.frx":B4E8
            TabIndex        =   26
            Text            =   "255"
            Top             =   2640
            Width           =   735
         End
         Begin VB.ComboBox CbB 
            Height          =   300
            ItemData        =   "FrmV1.frx":B4F4
            Left            =   7440
            List            =   "FrmV1.frx":B4FE
            TabIndex        =   27
            Text            =   "255"
            Top             =   2640
            Width           =   735
         End
         Begin VB.ComboBox Combo3 
            Height          =   315
            ItemData        =   "FrmV1.frx":B50A
            Left            =   3960
            List            =   "FrmV1.frx":B514
            TabIndex        =   24
            Text            =   "Black"
            Top             =   2640
            Width           =   855
         End
         Begin VB.CommandButton Command10 
            Caption         =   "Horizontal Line"
            Height          =   375
            Left            =   240
            TabIndex        =   28
            Top             =   3240
            Width           =   1335
         End
         Begin VB.CommandButton Command11 
            Caption         =   "Vertical Line"
            Height          =   375
            Left            =   1680
            TabIndex        =   29
            Top             =   3240
            Width           =   1335
         End
         Begin VB.CommandButton Command27 
            Caption         =   "Low Stack"
            Height          =   375
            Left            =   6240
            TabIndex        =   43
            Top             =   4440
            Width           =   975
         End
         Begin VB.Label Label23 
            Caption         =   "Cross Back"
            Height          =   255
            Left            =   1320
            TabIndex        =   88
            Top             =   3720
            Width           =   855
         End
         Begin VB.Label Label22 
            Caption         =   "Font :"
            Height          =   255
            Left            =   3720
            TabIndex        =   82
            Top             =   6600
            Width           =   495
         End
         Begin VB.Label Label21 
            Caption         =   "Back :"
            Height          =   255
            Left            =   2280
            TabIndex        =   81
            Top             =   6600
            Width           =   495
         End
         Begin VB.Label Label20 
            Caption         =   "Gray Level"
            Height          =   255
            Left            =   1320
            TabIndex        =   80
            Top             =   6600
            Width           =   855
         End
         Begin VB.Label Label19 
            Caption         =   "Text View"
            Height          =   255
            Left            =   240
            TabIndex        =   79
            Top             =   6600
            Width           =   855
         End
         Begin VB.Line Line9 
            X1              =   120
            X2              =   8280
            Y1              =   6360
            Y2              =   6360
         End
         Begin VB.Line Line8 
            X1              =   6960
            X2              =   6960
            Y1              =   3120
            Y2              =   4200
         End
         Begin VB.Label LbOo2 
            Caption         =   "At background  use keyboard + - will control  Gray + -"
            Height          =   255
            Left            =   3000
            TabIndex        =   78
            Top             =   1440
            Width           =   4095
         End
         Begin VB.Label LbOo1 
            Caption         =   "If key-in Gray value , The RGB will use same of Gray !"
            Height          =   255
            Left            =   3000
            TabIndex        =   77
            Top             =   1200
            Width           =   4095
         End
         Begin VB.Line Line7 
            X1              =   3960
            X2              =   3960
            Y1              =   4920
            Y2              =   4200
         End
         Begin VB.Label Label18 
            Caption         =   "Y :"
            Height          =   255
            Left            =   3120
            TabIndex        =   76
            Top             =   4440
            Width           =   255
         End
         Begin VB.Label Label17 
            Caption         =   "X :"
            Height          =   255
            Left            =   2280
            TabIndex        =   75
            Top             =   4440
            Width           =   255
         End
         Begin VB.Label Label16 
            Caption         =   "Dynamic"
            Height          =   255
            Left            =   240
            TabIndex        =   74
            Top             =   5880
            Width           =   855
         End
         Begin VB.Line Line6 
            X1              =   120
            X2              =   8280
            Y1              =   5640
            Y2              =   5640
         End
         Begin VB.Label Label15 
            Caption         =   "Uniformity"
            Height          =   255
            Left            =   240
            TabIndex        =   73
            Top             =   5160
            Width           =   1095
         End
         Begin VB.Line Line5 
            X1              =   120
            X2              =   8280
            Y1              =   4920
            Y2              =   4920
         End
         Begin VB.Label Label14 
            Caption         =   "Quick Back :"
            Height          =   255
            Left            =   360
            TabIndex        =   72
            Top             =   2040
            Width           =   975
         End
         Begin VB.Label Label13 
            Caption         =   "Contrast View"
            Height          =   255
            Left            =   240
            TabIndex        =   71
            Top             =   4440
            Width           =   1095
         End
         Begin VB.Line Line4 
            X1              =   120
            X2              =   6960
            Y1              =   4200
            Y2              =   4200
         End
         Begin VB.Label Label12 
            Caption         =   "Pixel Width :"
            Height          =   255
            Left            =   5040
            TabIndex        =   70
            Top             =   3720
            Width           =   975
         End
         Begin VB.Label Label11 
            Caption         =   "Pixel Width :"
            Height          =   255
            Left            =   5040
            TabIndex        =   69
            Top             =   3360
            Width           =   975
         End
         Begin VB.Label Label3 
            Caption         =   "Push Level"
            Height          =   255
            Left            =   6600
            TabIndex        =   68
            Top             =   360
            Width           =   855
         End
         Begin VB.Label Label4 
            Caption         =   "Gray"
            Height          =   255
            Left            =   4440
            TabIndex        =   67
            Top             =   360
            Width           =   495
         End
         Begin VB.Line Line1 
            X1              =   120
            X2              =   8280
            Y1              =   1800
            Y2              =   1800
         End
         Begin VB.Label Label2 
            Caption         =   "Push Level"
            Height          =   255
            Left            =   3240
            TabIndex        =   66
            Top             =   840
            Width           =   855
         End
         Begin VB.Label Label5 
            Caption         =   "Timer (100ms):"
            Height          =   255
            Left            =   4920
            TabIndex        =   65
            Top             =   840
            Width           =   1095
         End
         Begin VB.Label Label6 
            Caption         =   "  Level :"
            Height          =   255
            Left            =   1800
            TabIndex        =   64
            Top             =   2640
            Width           =   615
         End
         Begin VB.Label Label7 
            Caption         =   "To RGB :"
            Height          =   255
            Left            =   4920
            TabIndex        =   63
            Top             =   2640
            Width           =   735
         End
         Begin VB.Label Label1 
            BackColor       =   &H00E0E0E0&
            Caption         =   "0"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   12
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   375
            Left            =   0
            TabIndex        =   62
            Top             =   0
            Width           =   255
         End
         Begin VB.Label Label8 
            Caption         =   "From :"
            Height          =   255
            Left            =   3480
            TabIndex        =   61
            Top             =   2640
            Width           =   495
         End
         Begin VB.Line Line2 
            X1              =   120
            X2              =   8280
            Y1              =   2520
            Y2              =   2520
         End
         Begin VB.Line Line3 
            X1              =   120
            X2              =   8280
            Y1              =   3120
            Y2              =   3120
         End
         Begin VB.Label Label9 
            Caption         =   "Line1 Color"
            Height          =   255
            Left            =   3120
            TabIndex        =   60
            Top             =   3360
            Width           =   855
         End
         Begin VB.Label Label10 
            Caption         =   "Line2 Color"
            Height          =   255
            Left            =   3120
            TabIndex        =   59
            Top             =   3720
            Width           =   855
         End
      End
   End
End
Attribute VB_Name = "FrmV1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Public FrmMonitorSelectcmd As Long
Public TimeAdd As Integer
Public TimeSel As Integer
Public Time4Sel As Integer
Public BW As Boolean
Public CM2Color As String
Dim Cmd2Jng As Boolean
Dim MusDown As Boolean
Dim MusBotton As Integer
Dim KeyPS As Integer
Dim gTM As Integer

Public Function LanguBIG5()
If Langu = 1 Then
    Frame2.Caption = "     選擇你要測試的項目 , 進入測試畫面要停止請按滑鼠右鍵顯示本選單"
    Option2.Caption = "顯色 (R:G:B)"
    Option2.ToolTipText = "按下 在螢幕上測試設定 後顯示您所設定的 RGB 值打出來的顏色"
    Label4.Caption = "灰度"
    Label4.ToolTipText = "輸入後自動設定 RGB 三個數值為同一個值來打出灰階畫面 , 範圍為 0 到 255"
    CM2Gray.ToolTipText = Label4.ToolTipText
    CcGU(1).ToolTipText = "將灰度減少 , 減少值可在步進階數設定"
    CcGU(0).ToolTipText = "將灰度增加 , 增加值可在步進階數設定"
    Label3.Caption = "步進階數"
    Label3.ToolTipText = "按下 + 或 - 後要遞增或遞減多少灰階 , 許可作用範圍為 0 到 255"
    Text2.ToolTipText = Label3.ToolTipText
    Option1.Caption = "自動秀色彩"
    Option1.ToolTipText = "按下 在螢幕上測試設定 後會自動按照您在右方的設定打出畫面"
    Label2.Caption = Label3.Caption
    Label2.ToolTipText = "自動秀色彩時每一個畫面要遞增多少度色階或灰階"
    Label5.Caption = "間隔 (100ms):"
    Label5.ToolTipText = "使用自動秀色彩時轉換到下一個顏色或灰階的畫面要間隔多久"
    Command2.Caption = "在螢幕上測試設定"
    Command2.ToolTipText = "依照您在上方設定的參數與測試目標顯示到螢幕上"
    Command7.Caption = "(&C)結束"
    Command7.ToolTipText = "關閉測試畫面回到桌面"
    LbOo1.Caption = "在灰度輸入值會自動將 RGB 代入相同值"
    LbOo2.Caption = "在背景下按鍵盤 + - 將按步進階數即時改變灰度"
    '*******************************************************************
    Label14.Caption = "背景快顯"
    Label14.ToolTipText = "立即在螢幕上顯示全畫面的指定背景顏色 , 可以用來測試亮點與壞點以及色點"
    Check1.Caption = "顯示九宮線"
    Check1.ToolTipText = "在螢幕上顯示井字九宮格線 , 用以了解亮點位置是否符合更換面板之保固規定"
    Command1.Caption = "全白"
    Command3.Caption = "全黑"
    Command4.Caption = "全紅"
    Command5.Caption = "全綠"
    Command6.Caption = "全藍"
    '*******************************************************************
    Command9.Caption = "色階表"
    Command9.ToolTipText = "依照右方的設定 , 在螢幕上顯示由白或黑到指定 RGB 值顏色的所有色階 , 色階間隔按照階數而定"
    Label6.Caption = "    階數:"
    Label6.ToolTipText = "指定要顯示多少個色階 , 全顯示為 256 色"
    Combo2.ToolTipText = Label6.ToolTipText
    Label8.Caption = "起始:"
    Label8.ToolTipText = "設定啟始色(螢幕左方)為黑色(Black)或白色(White)"
    Combo3.ToolTipText = Label8.ToolTipText
    Label7.Caption = " 至RGB:"
    Label7.ToolTipText = "從白或黑開始按色階漸層遞增(減)到指定的 RGB 值"
    CbR.ToolTipText = "紅色(255,0,0) , 綠色(0,255,0) , 藍色(0,0,255) , 黃色(255,255,0) , 青藍(0,255,255) , 紫色(255,0,255) , 白色(255,255,255) , 黑色(0,0,0)"
    CbG.ToolTipText = "紅色(255,0,0) , 綠色(0,255,0) , 藍色(0,0,255) , 黃色(255,255,0) , 青藍(0,255,255) , 紫色(255,0,255) , 白色(255,255,255) , 黑色(0,0,0)"
    CbB.ToolTipText = "紅色(255,0,0) , 綠色(0,255,0) , 藍色(0,0,255) , 黃色(255,255,0) , 青藍(0,255,255) , 紫色(255,0,255) , 白色(255,255,255) , 黑色(0,0,0)"
    '*******************************************************************
    Command10.Caption = "顯示水平線"
    Command11.Caption = "顯示垂直線"
    Command33.Caption = "交叉網線"
    Command33.ToolTipText = "在螢幕上顯示兩條互相交錯成網狀的線"
    Command33.ToolTipText = "使用此功能時網線底色才有作用!線條1為水平線, 線條2為垂直線, 像素寬度為線與線的間隔"
    Label23.Caption = "網線底色"
    Label23.ToolTipText = "使用交叉網線功能時時背景顯示的顏色"
    Combo4.ToolTipText = Label23.ToolTipText
    Label9.Caption = "線條1色彩:"
    Label9.ToolTipText = "設定在水平線或垂直線的奇數條(交叉網線的橫線)之顏色"
    CbL1.ToolTipText = Label9.ToolTipText
    Label10.Caption = "線條2色彩:"
    Label10.ToolTipText = "設定在水平線或垂直線的偶數條(交叉網線的直線)之顏色"
    CbL2.ToolTipText = Label10.ToolTipText
    Label11.Caption = "像素寬度"
    Label11.ToolTipText = "設定線條 1 的粗細為多少像素寬"
    CbLW1.ToolTipText = Label11.ToolTipText
    Label12.Caption = "像素寬度"
    Label12.ToolTipText = "設定線條 2 的粗細為多少像素寬"
    CbLW2.ToolTipText = Label12.ToolTipText
    '********************************************************************
    Label13.Caption = "對比度檢視"
    Command8.Caption = "方塊"
    Command8.ToolTipText = "在螢幕上顯示黑白交錯的方塊用以觀察螢幕各處的對比度"
    TxCwX.ToolTipText = "設定水平(橫向)要顯示幾行方塊"
    Label17.ToolTipText = TxCwX.ToolTipText
    TxCwY.ToolTipText = "設定垂直(直向)要顯示幾列方塊"
    Label18.ToolTipText = TxCwY.ToolTipText
    Command14.Caption = "色彩牆"
    Command14.ToolTipText = "顯示紅藍綠光及各種顏色的色塊組成的色彩牆 , 便於在調顏色或色溫時觀察各種顏色的變化"
    Command16.Caption = "高亮堆疊"
    Command16.ToolTipText = "顯示色階相近的色塊觀察螢幕表現 ! 如果是非全彩(True Color)螢幕將表現不出 16 與 17 階的差別"
    Command28.Caption = "中亮堆疊"
    Command28.ToolTipText = "顯示色階相近的色塊觀察螢幕表現 ! 若為 6bit 色驅動 IC 則約兩階才看得出有變化"
    Command27.Caption = "低亮堆疊"
    Command27.ToolTipText = "觀察螢幕色階在低亮度時的表現 ! 若呈現一團黑則代表對比度不夠亮度太低"
    Command17.Caption = "黑暗堆疊"
    Command17.ToolTipText = "觀察螢幕在暗色下的表現 ! 若呈現一團黑則代表對比度不夠或亮度太低"
    '********************************************************************
    Label15.Caption = "均勻度"
    Label15.ToolTipText = "觀察同一顏色在螢幕中央和螢幕四個角的色彩表現 ! 若LCD 非廣角或色偏太嚴重將會看見不等的顏色 , CRT 角落無法聚束將會看見不同大小的方塊"
    Command12.Caption = "黑色"
    Command13.Caption = "白色"
    Command19.Caption = "灰階(128)"
    Command19.ToolTipText = "1.眼睛與螢幕中央等高然後觀察四個角的表現! 2.眼睛與右下角或左下角等高直視 , 然後抬頭看左上角或右上角及中間之方塊觀察色偏程度"
    Command20.Caption = "灰階(204)"
    Command20.ToolTipText = "1.眼睛與螢幕中央等高然後觀察四個角的表現! 2.眼睛與右下角或左下角等高直視 , 然後抬頭看左上角或右上角及中間之方塊觀察色偏程度"
    Command15.Caption = "紅色"
    Command15.ToolTipText = "1.眼睛與螢幕中央等高然後觀察四個角的表現! 2.眼睛與右下角或左下角等高直視 , 然後抬頭看左上角或右上角及中間之方塊觀察色偏程度"
    Command18.Caption = "綠色"
    Command18.ToolTipText = "1.眼睛與螢幕中央等高然後觀察四個角的表現! 2.眼睛與右下角或左下角等高直視 , 然後抬頭看左上角或右上角及中間之方塊觀察色偏程度"
    Command21.Caption = "藍色"
    Command21.ToolTipText = "1.眼睛與螢幕中央等高然後觀察四個角的表現! 2.眼睛與右下角或左下角等高直視 , 然後抬頭看左上角或右上角及中間之方塊觀察色偏程度"
    '*********************************************************************
    Label16.Caption = "動態性"
    CbT1.ToolTipText = "設定右方各動態性測試項目的間歇時間"
    Command22.Caption = "灰階波浪"
    Command22.ToolTipText = "在螢幕上不斷重複2階(黑白)到256階灰色色階表 ! 此功能在越寬的螢幕上越慢"
    Command23.Caption = "(反向)"
    Command23.ToolTipText = "功能同灰階波浪但在到達極點時會將顏色相反過來 ! 此功能在越寬的螢幕上越慢"
    Command24.Caption = "方塊"
    Command24.ToolTipText = "在螢幕上顯示一個方塊以順時針的方向不斷繞著螢幕邊緣跑"
    Command25.Caption = "圓"
    Command25.ToolTipText = "把一個大圓縮成小圓 , 根據設定的間歇時間抓取縮小過程中的圓形畫面大小"
    Command26(0).Caption = "全螢幕"
    Command26(0).ToolTipText = "整個螢幕在黑色與白色間切換"
    Command26(1).Caption = "三橫"
    Command26(1).ToolTipText = "螢幕顯示白黑白或黑白黑的三橫重疊的切換畫面"
    '*************************************************************************
    Label19.Caption = "文字檢視"
    Label19.ToolTipText = "在全螢幕上打出預設字體的文字句子 , 觀察螢幕各處的文字顯示清晰度"
    Label20.Caption = "色灰階度"
    Label20.ToolTipText = "設定螢幕背景或文字的色階灰階數值"
    Label21.Caption = "背景:"
    Label21.ToolTipText = "設定文字檢視畫面背景的色灰階度值"
    CbTxBK.ToolTipText = Label21.ToolTipText & " , 可手動輸入 0 到 255"
    Label22.Caption = "文字:"
    Label22.ToolTipText = "設定文字檢視畫面文字的色灰階度值"
    CbTxC.ToolTipText = Label22.ToolTipText & " , 可手動輸入 0 到 255"
    Command30.Caption = "文字1"
    Command30.ToolTipText = "將螢幕填滿同一句子 , 觀察各處的字體字形清晰度與大小是否有不同 , 也可以將背景和文字的色灰階度調至相近來觀察低對比文字清晰度"
    Command31.Caption = "文字2"
    Command31.ToolTipText = "將螢幕填滿同一句子 , 觀察小字型到大字型之清楚程度與字廓 , 也可以將背景和文字的色灰階度調至相近來觀察低對比文字清晰度"
    Command32.Caption = "文字3"
    Command32.ToolTipText = "將螢幕填滿各種文字 , 觀察各顏色之表現 , 也可以將背景和文字的色灰階度調至相近來觀察低對比文字清晰度"
End If
End Function

Private Sub Pic1Size()
    Picture1.Width = Me.ScaleWidth
    Picture1.Height = Me.ScaleHeight
End Sub

Private Sub CbB_KeyUp(KeyCode As Integer, Shift As Integer)
CbB.Text = 255
End Sub

Private Sub CbG_KeyUp(KeyCode As Integer, Shift As Integer)
CbG.Text = 255
End Sub

Private Sub CbL1_KeyPress(KeyAscii As Integer)
KeyAscii = 0
End Sub

Private Sub CbL2_KeyPress(KeyAscii As Integer)
KeyAscii = 0
End Sub

Private Sub CbLW1_KeyPress(KeyAscii As Integer)
KeyAscii = 0
End Sub

Private Sub CbLW2_KeyPress(KeyAscii As Integer)
KeyAscii = 0
End Sub

Private Sub CbR_KeyUp(KeyCode As Integer, Shift As Integer)
CbR.Text = 255
End Sub

Private Sub CbTxBK_Change()
If Val(CbTxBK.Text) < 0 Then CbTxBK.Text = 0
If Val(CbTxBK.Text) > 255 Then CbTxBK.Text = 255
End Sub

Private Sub CbTxBK_KeyPress(KeyAscii As Integer)
If KeyAscii <> 8 Then
If KeyAscii < 48 Or KeyAscii > 57 Then KeyAscii = 0
End If
End Sub

Private Sub CbTxC_Change()
If Val(CbTxC.Text) < 0 Then CbTxC.Text = 0
If Val(CbTxC.Text) > 255 Then CbTxC.Text = 255
End Sub

Private Sub CbTxC_KeyPress(KeyAscii As Integer)
If KeyAscii <> 8 Then
If KeyAscii < 48 Or KeyAscii > 57 Then KeyAscii = 0
End If
End Sub

Private Sub CcGU_Click(Index As Integer)

Dim GrayLv As Integer
If CM2Gray.Text = "" Then CM2Gray.Text = 0
GrayLv = Val(Text2.Text)
If Index = 0 Then CM2Gray.Text = Val(CM2Gray.Text) + GrayLv
If Index = 1 Then CM2Gray.Text = Val(CM2Gray.Text) - GrayLv
End Sub

Private Sub CM2Gray_Change()
For icsp1 = 0 To 2
        CM2RGB(icsp1).Text = CM2Gray.Text
Next
If Val(CM2Gray.Text) < 0 Then CM2Gray.Text = 0
If Val(CM2Gray.Text) > 255 Then CM2Gray.Text = 255
End Sub

Private Sub CM2RGB_Change(Index As Integer)
If Val(CM2RGB(Index).Text) < 0 Then CM2RGB(Index).Text = 0
If Val(CM2RGB(Index).Text) > 255 Then CM2RGB(Index).Text = 255

End Sub

Private Sub Combo1_KeyPress(KeyAscii As Integer)
KeyAscii = 0
End Sub

Private Sub Combo2_KeyUp(KeyCode As Integer, Shift As Integer)
Combo2.Text = 256
End Sub

Private Sub Combo3_Click()
If Combo3.Text = "White" Then
    BW = True
Else
    BW = False
End If
End Sub

Private Sub Combo4_KeyPress(KeyAscii As Integer)
KeyAscii = 0
End Sub

Private Sub Command1_Click()
Frame2.Visible = False
Picture1.BackColor = RGB(255, 255, 255)
If Check1.Value = 1 Then Line9a (RGB(255, 255, 255) - Picture1.BackColor)
End Sub

Public Function Line9a(n As Long)
Dim MnW, MnH, Mi, MTmp, Mtmp2 As Long

MnW = Picture1.Width
MnH = Picture1.Height

Picture1.Line (0, MnH / 3)-(MnW, MnH / 3), n
Picture1.Line (0, 2 * MnH / 3)-(MnW, 2 * MnH / 3), n
Picture1.Line (MnW / 3, 0)-(MnW / 3, MnH), n
Picture1.Line (2 * MnW / 3, 0)-(2 * MnW / 3, MnH), n

End Function

Public Function SelectWordColor(s As String) As Long
Dim TmpC As Long

Select Case s
    Case "White"
        TmpC = RGB(255, 255, 255)
    Case "Black"
        TmpC = RGB(0, 0, 0)
    Case "Red"
        TmpC = RGB(255, 0, 0)
    Case "Green"
        TmpC = RGB(0, 255, 0)
    Case "Blue"
        TmpC = RGB(0, 0, 255)
End Select

SelectWordColor = TmpC
End Function

Private Sub Command10_Click()
Dim i As Long
Dim j, LP1, LP2 As Integer
Dim S1Color, S2Color As Long
Dim MnW, MnH, Mi, MTmp, Mtmp2 As Long

Frame2.Visible = False

MnW = Picture1.Width
MnH = Picture1.Height
LP1 = Val(CbLW1.Text)
LP2 = Val(CbLW2.Text)

S1Color = SelectWordColor(CbL1.Text)
S2Color = SelectWordColor(CbL2.Text)
MTmp = 1
Mtmp2 = 5252

For i = 0 To (MnH / 15)
    If MTmp <= LP1 And Mtmp2 = 5252 Then
        MTmp = MTmp + 1
            Picture1.Line (0, i * 15)-(MnW, i * 15 + 14), S1Color, BF
        If MTmp > LP1 Then
            MTmp = 5252
            Mtmp2 = 1
        End If
        GoTo JccLine1
    End If
    If Mtmp2 <= LP2 And MTmp = 5252 Then
        Mtmp2 = Mtmp2 + 1
            Picture1.Line (0, i * 15)-(MnW, i * 15 + 14), S2Color, BF
        If Mtmp2 > LP2 Then
            MTmp = 1
            Mtmp2 = 5252
        End If
    End If

JccLine1:
Next i

End Sub

Private Sub Command11_Click()
Dim i As Long
Dim j, LP1, LP2 As Integer
Dim S1Color, S2Color As Long
Dim MnW, MnH, Mi, MTmp, Mtmp2 As Long

Frame2.Visible = False

MnW = Picture1.Width
MnH = Picture1.Height
LP1 = Val(CbLW1.Text)
LP2 = Val(CbLW2.Text)

S1Color = SelectWordColor(CbL1.Text)
S2Color = SelectWordColor(CbL2.Text)
MTmp = 1
Mtmp2 = 5252

For i = 0 To (MnW / 15)
    If MTmp <= LP1 And Mtmp2 = 5252 Then
        MTmp = MTmp + 1
            Picture1.Line (i * 15, 0)-(i * 15 + 14, MnH), S1Color, BF
        If MTmp > LP1 Then
            MTmp = 5252
            Mtmp2 = 1
        End If
        GoTo JccLine1
    End If
    If Mtmp2 <= LP2 And MTmp = 5252 Then
        Mtmp2 = Mtmp2 + 1
            Picture1.Line (i * 15, 0)-(i * 15 + 14, MnH), S2Color, BF
        If Mtmp2 > LP2 Then
            MTmp = 1
            Mtmp2 = 5252
        End If
    End If

JccLine1:
Next i

End Sub

Private Function Uniformity(CcUni As Long, CcBK As Long)
Dim i, j, k, Vx1, Vx2 As Integer
Dim MnW, MnH, Mi, MTmp1, Mtmp2 As Long
Dim MaW, MaH, HalfX, HalfY, McX, McY, TmpXs As Long

Frame2.Visible = False
Picture1.BackColor = CcBK

MnW = Picture1.Width
MnH = Picture1.Height
MaW = MnW / 4
MaH = MnH / 4
HalfX = MnW / 2
HalfY = MnH / 2
McX = HalfX - (MaW / 2)
McY = HalfY - (MaH / 2)

Picture1.Line (McX, McY)-(McX + MaW, McY + MaH), CcUni, BF
Picture1.Line (0, 0)-(MaW, MaH), CcUni, BF
Picture1.Line (0, MnH)-(MaW, MnH - MaH), CcUni, BF
Picture1.Line (MnW, 0)-(MnW - MaW, MaH), CcUni, BF
Picture1.Line (MnW, MnH)-(MnW - MaW, MnH - MaH), CcUni, BF

End Function

Private Sub Command12_Click()
Uniformity vbBlack, vbWhite
End Sub

Private Sub Command13_Click()
Uniformity vbWhite, vbBlack
End Sub

Private Sub Command14_Click()
Dim i, j, k, Vx1, Vx2 As Integer
Dim MnW, MnH, Mi, MTmp1, Mtmp2 As Long
Dim MaW, MaH, HalfX, HalfY, BWidth, BHeight, TmpXs As Long
Dim C1W, C1H, C1RH, C1GH, C1BH, C1WH, C1W2H As Long
Dim D1Y, D1H, D1W, DxRY, DxGY, DxBY As Long
Dim ColorV(0 To 7), crT(0 To 18), crT1(1 To 18) As Long

Frame2.Visible = False
Picture1.BackColor = vbBlack

MnW = Picture1.Width
MnH = Picture1.Height
MaW = MnW / 16
MaH = MnH / 6
HalfX = MnW / 2
HalfY = MnH / 2
BWidth = MnW / 64
BHeight = MnH / 64
C1W = HalfX / 256
C1H = MnH / 32
C1RH = 3 * C1H
C1GH = 4 * C1H
C1BH = 5 * C1H
C1WH = 6 * C1H
C1W2H = 7 * C1H

For i = 0 To 255 'Rainbow
    Picture1.Line (i * C1W, C1RH)-((i + 1) * C1W, C1GH), RGB(i, 0, 0), BF: Picture1.Line (HalfX + (i * C1W), C1RH)-(HalfX + ((i + 1) * C1W), C1GH), RGB(255, i, i), BF
    Picture1.Line (i * C1W, C1GH)-((i + 1) * C1W, C1BH), RGB(0, i, 0), BF: Picture1.Line (HalfX + (i * C1W), C1GH)-(HalfX + ((i + 1) * C1W), C1BH), RGB(i, 255, i), BF
    Picture1.Line (i * C1W, C1BH)-((i + 1) * C1W, C1WH), RGB(0, 0, i), BF: Picture1.Line (HalfX + (i * C1W), C1BH)-(HalfX + ((i + 1) * C1W), C1WH), RGB(i, i, 255), BF
    Picture1.Line (i * C1W * 2, C1WH + C1H)-((i + 1) * C1W * 2, C1W2H + C1H), RGB(i, i, i), BF
Next


ColorV(0) = RGB(255, 0, 255)
ColorV(1) = RGB(255, 0, 127)
ColorV(2) = RGB(255, 0, 0)
ColorV(3) = RGB(255, 127, 0)
ColorV(4) = RGB(255, 255, 0)
ColorV(5) = RGB(0, 255, 0)
ColorV(6) = RGB(0, 255, 255)
ColorV(7) = RGB(0, 0, 255)

crT(0) = RGB(0, 0, 0)
For k = 1 To 6
Vx1 = CInt((2 - (k Mod 2)) * 127.5)
Vx2 = CInt(Int((k - 1) / 2) * 127.5)
crT(k) = RGB(Vx1, Vx2, 0)
crT(k + 6) = RGB(0, Vx1, Vx2)
crT(k + 12) = RGB(Vx2, 0, Vx1)
Next
For k = 1 To 3
    crT1(k * 6 - 5) = crT(k * 6 - 4)
    crT1(k * 6 - 4) = crT(k * 6 - 5)
    crT1(k * 6 - 3) = crT(k * 6 - 2)
    crT1(k * 6 - 2) = crT(k * 6)
    crT1(k * 6 - 1) = crT(k * 6 - 3)
    crT1(k * 6) = crT(k * 6 - 1)
Next
For k = 1 To 15
    crT(k + 3) = crT1(k)
Next
For k = 1 To 3
    crT(k) = crT1(k + 15)
Next

TmpXs = HalfX - (4 * MaW) - (4 * BWidth)

For i = 0 To 7
    MTmp1 = TmpXs + i * (MaW + BWidth)
    Picture1.Line (MTmp1, HalfY - MaH - BHeight)-(MTmp1 + MaW, HalfY - BHeight), ColorV(i), BF
Next

Mtmp2 = TmpXs
For j = 0 To 18
    Picture1.Line (Mtmp2, HalfY + BHeight)-(Mtmp2 + BWidth, HalfY + BHeight + MaH), crT(j), BF
    Mtmp2 = Mtmp2 + BWidth * 2
Next

D1Y = HalfY + 6 * BHeight + MaH 'Get RGB Color 16 Table start Height
D1H = (MnH - D1Y) / 3
D1W = MnW / 16
DxRY = D1Y
DxGY = DxRY + D1H
DxBY = DxGY + D1H

For i = 0 To 15
    Picture1.Line (i * D1W, DxRY)-((i + 1) * D1W, DxGY), RGB(i * 17, 0, 0), BF
    Picture1.Line (i * D1W, DxGY)-((i + 1) * D1W, DxBY), RGB(0, i * 17, 0), BF
    Picture1.Line (i * D1W, DxBY)-((i + 1) * D1W, MnH), RGB(0, 0, i * 17), BF
Next

End Sub

Private Function LevelStack(SColor As Integer, EColor As Integer, CStep As Integer, WordColorA As Long)
Dim i, j, k, Vx1, Vx2 As Integer
Dim MnW, MnH, Mi, MTmp1, Mtmp2 As Long
Dim MaW, MaH, MbW, MbH, BWidth, BHeight, TmpXs As Long
Dim ColorV(1 To 13), crT(1 To 10), crT1(1 To 18) As Long

Frame2.Visible = False
Picture1.ForeColor = WordColorA

MnW = Picture1.Width
MnH = Picture1.Height
MbW = MnW
MbH = MnH
MaW = 0
MaH = 0
BWidth = MnW / 64
BHeight = MnH / 64

For i = SColor To EColor Step CStep
    Picture1.Line (MaW, MaH)-(MbW, MbH), RGB(i, i, i), BF
    Vx1 = Abs((i - SColor) / CStep)
    Picture1.Print Vx1
    MaW = MaW + BWidth
    MbW = MbW - BWidth
    MaH = MaH + BHeight
    MbH = MbH - BHeight
Next
i = i - CStep
Vx1 = Vx1 + 1
Picture1.PSet (MbW, MbH), RGB(i, i, i)
Picture1.Print Vx1

If Langu = 1 Then
Picture1.PSet (CInt(MnW / 2.7), (MnH / 2.5)), RGB(i, i, i)
Picture1.Print "自灰階 " & SColor & " 至 " & EColor & " 間隔 " & CStep & " 度灰階"
Picture1.PSet (CInt(MnW / 2.7), (MnH / 2.3)), RGB(i, i, i)
Picture1.Print "如果您無法清楚辨別 " & Vx1 & " 個階層 , 請檢查您的螢幕 !"
Else
Picture1.PSet (CInt(MnW / 2.7), (MnH / 2.5)), RGB(i, i, i)
Picture1.Print "From Gray Level " & SColor & " to " & EColor & " Step " & CStep
Picture1.PSet (CInt(MnW / 2.7), (MnH / 2.3)), RGB(i, i, i)
Picture1.Print "If it's not discriminable " & Vx1 & " level, Check your monitor !"
End If

End Function

Private Sub Command15_Click()
Uniformity RGB(255, 0, 0), vbBlack
End Sub

Private Sub Command16_Click()
LevelStack 207, 255, 3, vbBlack
End Sub

Private Sub Command17_Click()
LevelStack 48, 0, -3, vbWhite
End Sub

Private Sub Command18_Click()
Uniformity RGB(0, 255, 0), vbBlack
End Sub

Private Sub Command19_Click()
Uniformity RGB(128, 128, 128), vbBlack
End Sub

Private Sub Command2_Click()
Dim i, j, Lev As Integer
Dim rr, gg, bb As Integer

Frame2.Visible = False

If Option2.Value = True Then
    CM2Color = "&H" & HexColor(CM2RGB(0).Text) & HexColor(CM2RGB(1).Text) & HexColor(CM2RGB(2).Text)
    Picture1.BackColor = CM2Color
    KeyPS = 1
End If

If Option1.Value = True Then
    Lev = CInt(Val(Text1.Text))
    Cmd2Jng = True
    For i = 0 To 500 Step Lev
        If Combo1.Text = "Gray" Then
            rr = i
            gg = i
            bb = i
        ElseIf Combo1.Text = "Red" Then rr = i
        ElseIf Combo1.Text = "Green" Then gg = i
        ElseIf Combo1.Text = "Blue" Then bb = i
        End If
        CM2Color = "&H" & HexColor(CStr(bb)) & HexColor(CStr(gg)) & HexColor(CStr(rr))
        Picture1.BackColor = CM2Color
        Sleep CInt(Val(Text3.Text) * 99)
        DoEvents
        If i + Lev > 255 Then Lev = 255 - i
        If i >= 255 Then MsgBox "Auto Run Complated": Exit Sub
        If Cmd2Jng = False Then MsgBox "Auto Run Stop!": Exit Sub
    Next
End If

End Sub

Private Sub Command20_Click()
Uniformity RGB(204, 204, 204), vbBlack
End Sub

Private Sub Command21_Click()
Uniformity RGB(0, 0, 255), vbBlack
End Sub


Private Sub Command22_Click()
Frame2.Visible = False
TimeSel = 1
TimeAdd = 0
Timer1.Interval = Val(CbT1.Text)
Timer1.Enabled = True
End Sub

Private Sub Command23_Click()
Frame2.Visible = False
TimeSel = 2
TimeAdd = 0
Timer1.Interval = Val(CbT1.Text)
Timer1.Enabled = True
End Sub

Private Sub Command24_Click()

Frame2.Visible = False
Picture1.BackColor = vbWhite
TimeAdd = 0
Timer2.Interval = Val(CbT1.Text)
Timer2.Enabled = True

End Sub

Private Sub Command25_Click()

Frame2.Visible = False
Picture1.BackColor = vbWhite
Picture1.FillColor = vbBlack
TimeAdd = 0
Timer3.Interval = Val(CbT1.Text)
If Val(CbT1.Text) > 500 Then CbT1.Text = "500ms"
Timer3.Enabled = True

End Sub


Private Sub Command26_Click(Index As Integer)
Frame2.Visible = False
Picture1.BackColor = vbWhite
Picture1.FillColor = vbBlack
TimeAdd = 0
Time4Sel = Index + 1
Timer4.Interval = Val(CbT1.Text)
Timer4.Enabled = True
End Sub

Private Sub Command27_Click()
LevelStack 72, 0, -6, vbWhite
End Sub

Private Sub Command28_Click()
LevelStack 110, 172, 2, vbWhite
End Sub

Private Sub Command3_Click()
Frame2.Visible = False
Picture1.BackColor = RGB(0, 0, 0)
If Check1.Value = 1 Then Line9a (RGB(255, 255, 255) - Picture1.BackColor)
End Sub

Private Sub Command30_Click()
Dim i, j, FonSize As Long
Dim ScrText, tmpTx As String
Dim MnW, MnH, MtW, MtH, CBK, CC As Long
Frame2.Visible = False
FonSize = Picture1.FontSize
Picture1.Cls
If Langu = 0 Then
    ScrText = "HomeRun!CCF52Hero "
ElseIf Langu = 1 Then
    ScrText = "陳金鋒全壘打！"
End If

MnW = Picture1.Width
MnH = Picture1.Height
MtW = MnW / 15 / 70
MtH = MnH / 15 / 10

CBK = CInt(CbTxBK.Text)
CC = CInt(CbTxC.Text)
Picture1.BackColor = RGB(CBK, CBK, CBK)
Picture1.ForeColor = RGB(CC, CC, CC)
Picture1.FontSize = 8

tmpTx = ""
For i = 1 To MtW
tmpTx = tmpTx & ScrText
Next

For i = 1 To MtH
Picture1.Print tmpTx
Next

Picture1.FontSize = FonSize

End Sub

Private Sub Command31_Click()
Dim i, j, FonSize As Long
Dim ScrText, tmpTx As String
Dim FonNameTmp As Variant
Dim MnW, MnH, MtW, MtH, CBK, CC As Long
Frame2.Visible = False
FonSize = Picture1.FontSize
Picture1.Cls
If Langu = 0 Then
    FonNameTmp = Picture1.Font.Name
    Picture1.Font.Name = "MS Serif"
    ScrText = "Zuso ptt PCDVD MSOG MIDI MALL "
ElseIf Langu = 1 Then
    ScrText = "極光駭客　龍龘馬驫　極光駭客　心惢日晶　極光駭客　土垚金鑫　"
End If

MnW = Picture1.Width
MnH = Picture1.Height
MtW = MnW / 15 / 70
MtH = MnH / 15 / 10

CBK = CInt(CbTxBK.Text)
CC = CInt(CbTxC.Text)
Picture1.BackColor = RGB(CBK, CBK, CBK)
Picture1.ForeColor = RGB(CC, CC, CC)
Picture1.FontSize = 8

tmpTx = ""
For i = 1 To MtW
tmpTx = tmpTx & ScrText
Next

For i = 0 To MtH
Picture1.FontSize = i Mod 9 + 6 - 0.25 * (i Mod 9)
Picture1.Print "Size:" & CStr(Picture1.FontSize) & "  " & tmpTx
If (i Mod 9) = 8 Then
    Picture1.FontSize = 2
    Picture1.Print " "
End If

Next

If Langu = 0 Then Picture1.Font.Name = FonNameTmp
Picture1.FontSize = FonSize
End Sub

Private Sub Command32_Click()
Dim i, j, FonSize As Long
Dim ScrText(0 To 4), tmpTx(0 To 4) As String
Dim tmpCw(0 To 7) As Long
Dim MnW, MnH, MtW, MtH, CBK, CC As Long
Frame2.Visible = False
FonSize = Picture1.FontSize
Picture1.Cls
If Langu = 0 Then
    ScrText(0) = "USA:Barry Bonds! DOMINICAN:Sammy Sosa! JAPAN:Matsui Hideki! KOREA:Seung-Yeop Lee! TAIWAN:Chin-Feng Chen! "
    ScrText(1) = "Chin-Feng Chen, the best baseball Hitter of Taiwan. Outfielder, and he is a Slugger, Clean Up Batter, specially Home Run the Ace Pitcher. You give him a chance, he gives your team Home-Run and Win!!Ball come than hit."
    ScrText(2) = "Thanks for using this software. ISee Monitor Test need your opinion, added new function, or fixed bug.  "
    ScrText(3) = "If you use the Auto Color Show, it's will start on Black and stop on your setting color level 255 step push level."
    ScrText(4) = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz,.`~!@#$%^&*(|) -_+ \_/ ...>""< =.= A_A V_V >o< :;"
ElseIf Langu = 1 Then
    ScrText(0) = "1998年第一次在世界盃打棒球就得了全壘打王,2001年打贏了日本隊轟出雙響砲,接著連續六年棒打所有日本王牌投手,贏得全日本最不想面對打者冠軍!中國古擊法唯一傳人陳金鋒,被喻為日本殺手,綽號「台灣巨砲」 "
    ScrText(1) = "你知道嗎？在文字檢視功能中的背景和文字顏色可以輸入 0 到 255 自訂階度喔！使用交叉網線功能時，線條1為水平線，線條2為垂直線，像素寬度為線與線的間隔距離。在背景快顯時顯示九宮線，可以檢視自己的亮暗點是否在保固規則的可更換區。"
    ScrText(2) = "會怕就好！球來就打。叫你總仔出來打啦！很會打全壘打嗎？曾公不要打我，從東京打到北京；鋒砲炸裂了！簡樸打球，共體時艱？點．．１１３，你的四零榴呢？免肖想！辛辛苦苦的寫軟體卻得不到應有的待遇※"
    ScrText(3) = "黃龍義㊣余進德∮林智勝★陳金鋒∞蔣智聰≧曾豪駒￡石志偉⊙蔡建偉←陳峰民⊕林聖凱￥徐余偉▼許文雄∩蔡英峰∵許志華ψ李風華Ω黃俊中∫VS.！1.SS.胡金龍 2.RF.彭政閔 3.2B.陳鏞基 4.DH.陳金鋒 5.LF.林威助 6.1B.林智勝 7.CF.謝佳賢 8.3B.張泰山 9.C.陳峰民！VS."
    ScrText(4) = "在流沙中找自己，在沙灘上遇見似曾相識的小鎮姑娘，只是普通朋友的她討厭紅樓夢，但我喜歡！等在飛機場的十點半我咬了一口黑色柳丁，這寂寞的季節，天天說走就走。"
End If

MnW = Picture1.Width
MnH = Picture1.Height
MtW = MnW / 15 / 200
MtH = MnH / 15 / 10

CBK = CInt(CbTxBK.Text)
CC = CInt(CbTxC.Text)
Picture1.BackColor = RGB(CBK, CBK, CBK)
'Picture1.ForeColor = RGB(CC, CC, CC)
Picture1.FontSize = 9.75

tmpTx(0) = "": tmpTx(1) = "": tmpTx(2) = "": tmpTx(3) = "": tmpTx(4) = ""
tmpCw(0) = RGB(0, 0, 0)
tmpCw(1) = RGB(CC, 0, 0)
tmpCw(2) = RGB(CC, CC, 0)
tmpCw(3) = RGB(0, CC, 0)
tmpCw(4) = RGB(0, CC, CC)
tmpCw(5) = RGB(0, 0, CC)
tmpCw(6) = RGB(CC, 0, CC)
tmpCw(7) = RGB(CC, CC, CC)
For i = 1 To MtW
tmpTx(0) = tmpTx(0) & ScrText(0)
tmpTx(1) = tmpTx(1) & ScrText(1)
tmpTx(2) = tmpTx(2) & ScrText(2)
tmpTx(3) = tmpTx(3) & ScrText(3)
tmpTx(4) = tmpTx(4) & ScrText(4)
Next

For i = 0 To MtH
Picture1.ForeColor = tmpCw(i Mod 8)
Picture1.Print tmpTx(i Mod 5)
tmpTx(i Mod 5) = Mid$(tmpTx(i Mod 5), 31, Len(tmpTx(i Mod 5))) & Mid$(tmpTx(i Mod 5), 1, 30)
Next

Picture1.FontSize = FonSize
End Sub

Private Sub Command33_Click()
Dim i As Long
Dim j, LP1, LP2 As Integer
Dim S1Color, S2Color As Long
Dim MnW, MnH, Mi As Long

Frame2.Visible = False
Select Case Combo4.Text
    Case "Black"
        Mi = RGB(0, 0, 0)
    Case "White"
        Mi = RGB(255, 255, 255)
    Case "Red"
        Mi = vbRed
    Case "Green"
        Mi = RGB(0, 255, 0)
    Case "Blue"
        Mi = RGB(0, 0, 255)
    Case "Gray"
        Mi = RGB(128, 128, 128)
End Select

MnW = Picture1.Width
MnH = Picture1.Height
LP1 = Val(CbLW1.Text)
LP2 = Val(CbLW2.Text)
Picture1.BackColor = Mi

S1Color = SelectWordColor(CbL1.Text)
S2Color = SelectWordColor(CbL2.Text)
MTmp = 1

For i = 0 To (MnH / 15)
    If i Mod (LP1 + 1) = 0 Then
        Picture1.Line (0, i * 15)-(MnW, i * 15), S1Color
    End If
Next i

For i = 0 To (MnW / 15)
    If i Mod (LP2 + 1) = 0 Then
        Picture1.Line (i * 15, 0)-(i * 15, MnH), S2Color
    End If
Next i

End Sub

Private Sub Command4_Click()
Frame2.Visible = False
Picture1.BackColor = RGB(255, 0, 0)
If Check1.Value = 1 Then Line9a (RGB(255, 255, 255) - Picture1.BackColor)
End Sub

Private Sub Command5_Click()
Frame2.Visible = False
Picture1.BackColor = RGB(0, 255, 0)
If Check1.Value = 1 Then Line9a (RGB(255, 255, 255) - Picture1.BackColor)
End Sub

Private Sub Command6_Click()
Frame2.Visible = False
Picture1.BackColor = RGB(0, 0, 255)
If Check1.Value = 1 Then Line9a (RGB(255, 255, 255) - Picture1.BackColor)
End Sub

Private Sub Command7_Click()
Unload Me

End Sub


Private Sub Command8_Click()
Dim i, j As Integer
Dim MnW, MnH, Mi, MColor As Long
Dim M4W, M4H, MTmp, WX, WY As Long

Frame2.Visible = False

MnW = Picture1.Width
MnH = Picture1.Height
WX = Int(TxCwX.Text)
WY = Int(TxCwY.Text)

M4W = MnW / WX
M4H = MnH / WY

For i = 1 To WX
For j = 1 To WY
If (i + j) Mod 2 = 0 Then
    MColor = RGB(0, 0, 0)
Else
    MColor = RGB(255, 255, 255)
End If

Picture1.Line ((i - 1) * M4W, (j - 1) * M4H)-(i * M4W - 1, j * M4H - 1), MColor, BF
'DoEvents

Next j
Next i


End Sub

Private Sub Command9_Click()
Frame2.Visible = False
DoEvents
If BW = False Then
    GTable Val(CbR.Text), Val(CbG.Text), Val(CbB.Text), Val(Combo2.Text), BW
Else
    GTable 255 - Val(CbR.Text), 255 - Val(CbG.Text), 255 - Val(CbB.Text), Val(Combo2.Text), BW
End If

End Sub

Private Function GTable(tCR As Integer, tCG As Integer, tCB As Integer, CLevel As Integer, CRtoL As Boolean)
Dim CR, CG, CB As Integer
Dim rr As Integer, gg As Integer, bb As Integer
Dim MnW, MnH, Mi As Long
Dim McW, McWP, McTmp As Double
Dim McWR, McWG, McWB, McWRP, McWGP, McWBP As Double

MnW = Picture1.Width / 15
MnH = Picture1.Height / 15
McW = MnW / 256
McWP = McW

CR = tCR
CG = tCG
CB = tCB

'CR = 255 - tCR
'CG = 255 - tCG
'CB = 255 - tCB

'McWR = (MnW / CLevel) * (256 - CR)
'McWG = (MnW / CLevel) * (256 - CG)
'McWB = (MnW / CLevel) * (256 - CB)
McWR = (MnW / CLevel) * (256 - CR)
McWG = (MnW / CLevel) * (256 - CG)
McWB = (MnW / CLevel) * (256 - CB)
McWRP = McWR
McWGP = McWG
McWBP = McWB

For Mi = 0 To MnW
    If Mi - McWR > 0 Then
        McWR = McWR + McWRP
        rr = rr + Int(255 / (CLevel - 1))
    End If
    If Mi - McWG > 0 Then
        McWG = McWG + McWGP
        gg = gg + Int(255 / (CLevel - 1))
    End If
    If Mi - McWB > 0 Then
        McWB = McWB + McWBP
        bb = bb + Int(255 / (CLevel - 1))
    End If
    If rr > 255 Then rr = 255
    If gg > 255 Then gg = 255
    If bb > 255 Then bb = 255
    If CRtoL = False Then
        Picture1.Line (Mi * 15, 0)-(Mi * 15 + 14, MnH * 15), RGB(rr, gg, bb), BF
    Else
        Picture1.Line (Mi * 15, 0)-(Mi * 15 + 14, MnH * 15), RGB(255 - rr, 255 - gg, 255 - bb), BF
    End If
Next

End Function

Private Sub Form_Load()


'Read FrmMonitorSelect Value to change the display range
Me.Move FrmMonitorSelect.CM2Left, FrmMonitorSelect.CM2Top, FrmMonitorSelect.CM2Width, FrmMonitorSelect.CM2Height

FrmMonitorSelectcmd = FrmMonitorSelect.ChooseMonitorCommand
Label1.Caption = FrmMonitorSelectcmd


'*******set picture1 height width
Call Pic1Size
LanguBIG5
'*******set the display desktop

'If FrmMonitorSelect.Option1.Value = True Then
'    Picture1.Picture = LoadPicture(FrmMonitorSelect.Text1.Text)
'End If

'If FrmMonitorSelect.Option2.Value = True Then
'    Picture1.BackColor = FrmMonitorSelect.CM2Color
'End If

End Sub

Private Sub Form_Resize()
Call Pic1Size
End Sub

Private Sub Label1_Click()
    Label1.Visible = False
End Sub

Private Sub Picture1_KeyPress(KeyAscii As Integer)

    If KeyAscii = 43 Then
        CcGU_Click (0)
        Command2_Click
    ElseIf KeyAscii = 45 Then
        CcGU_Click (1)
        Command2_Click
    End If


End Sub

Private Sub Picture1_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
MusDown = True
If Button = 1 Then
    Label1.Visible = False
    Frame2.Visible = False
    MusBotton = 1
ElseIf Button = 2 Then
    Timer1.Enabled = False
    Timer2.Enabled = False
    Timer3.Enabled = False
    Timer4.Enabled = False
    Label1.Visible = True
    Frame2.Visible = True
    Cmd2Jng = False
    MusBotton = 2
End If

End Sub

Private Sub Text2_Change()
If Text2.Text = "" Then Text2.Text = 1
End Sub

Private Sub Timer1_Timer()

TimeAdd = TimeAdd + 1

If TimeAdd < 8 Then
    GTable 255, 255, 255, 2 ^ TimeAdd, False
Else
    If TimeSel = 1 Then
        GTable 255, 255, 255, 2 ^ (16 - TimeAdd), False
    ElseIf TimeSel = 2 Then
        GTable 255, 255, 255, 2 ^ (16 - TimeAdd), True
    End If
End If

If TimeAdd = 15 Then TimeAdd = 0
        
End Sub


Private Sub Timer2_Timer()

Dim MnW, MnH As Long
Dim MaW, MaH As Long

TimeAdd = TimeAdd + 1
MnW = Picture1.Width
MnH = Picture1.Height
MaW = MnW / 5
MaH = MnH / 5
Picture1.Cls

Select Case TimeAdd
    Case 1 To 5
        Picture1.Line ((TimeAdd - 1) * MaW, 0)-(TimeAdd * MaW, MaH), vbBlack, BF
    Case 6 To 9
        Picture1.Line (MnW - MaW, (TimeAdd - 5) * MaH)-(MnW, (TimeAdd - 4) * MaH), vbBlack, BF
    Case 10 To 13
        Picture1.Line ((13 - TimeAdd) * MaW, MnH - MaH)-((14 - TimeAdd) * MaW, MnH), vbBlack, BF
    Case 14 To 16
        Picture1.Line (0, (17 - TimeAdd) * MaH)-(MaW, (18 - TimeAdd) * MaH), vbBlack, BF
End Select

If TimeAdd = 16 Then TimeAdd = 0


End Sub

Private Sub Timer3_Timer()
Dim MnW, MnH, MCut As Long
Dim MaW, MaH, HfW, HfH As Long

TimeAdd = TimeAdd + 1
MCut = CLng(1000 / Val(CbT1.Text))
MnW = Picture1.Width
MnH = Picture1.Height
HfW = MnW / 2
HfH = MnH / 2
MaW = (HfW - MnW / 24) / MCut
MaH = (HfH - MnH / 24) / MCut
Picture1.Cls

Picture1.Circle (HfW, HfH), HfH - TimeAdd * MaH, vbBlack

If TimeAdd = MCut Then
    TimeAdd = 0
    Dim i As Integer
    For i = 0 To 50
        Sleep (100)
        DoEvents
    Next i
End If
End Sub

Private Sub Timer4_Timer()
Dim MnW, MnH, MCut As Long
Dim MaW, MaH, TfW, TfH As Long

TimeAdd = TimeAdd + 1
MnW = Picture1.Width
MnH = Picture1.Height
TfW = MnW / 3
TfH = MnH / 3

Select Case Time4Sel
Case 1
    If TimeAdd = 1 Then
        Picture1.BackColor = vbBlack
    Else
        Picture1.BackColor = vbWhite
        TimeAdd = 0
    End If
Case 2
    'Picture1.Cls
    If TimeAdd = 1 Then
        Picture1.BackColor = vbBlack
        Picture1.Line (0, TfH)-(MnW, TfH + TfH), vbWhite, BF
    Else
        Picture1.BackColor = vbWhite
        Picture1.Line (0, TfH)-(MnW, TfH + TfH), vbBlack, BF
        TimeAdd = 0
    End If
End Select

End Sub
