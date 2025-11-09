VERSION 5.00
Begin VB.Form FrmWC 
   BorderStyle     =   0  '沒有框線
   Caption         =   "Exit"
   ClientHeight    =   870
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   855
   Icon            =   "FrmWC.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   870
   ScaleWidth      =   855
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  '系統預設值
   Begin VB.Timer Timer1 
      Interval        =   10
      Left            =   120
      Top             =   240
   End
End
Attribute VB_Name = "FrmWC"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Timer1_Timer()
FrmMonitorSelect.Show
Unload Me
End Sub
