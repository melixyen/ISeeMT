Attribute VB_Name = "modMonitors"
Public Langu As Integer 'English=0 , Chinese=1
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Public Const SW_SHOWNORMAL = 1
Public IPEXCH As Boolean

Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long



'typedef BOOL (CALLBACK* MONITORENUMPROC)(HMONITOR, HDC, LPRECT, LPARAM);
Public Function MonitorEnumProc(hMonitor As Long, hdc As Long, lpRect As Long, lparam As Long)
    Debug.Print "Monitor: " & hMonitor
End Function


Public Function HexColor(nr As String)
    
'********This Will Trans Dec to Double HEX*******************
    If nr = "" Then nr = "0"

    If Val(nr) < 16 Then
        HexColor = "0" & Hex$(nr)
    ElseIf Val(nr) >= 16 And Val(nr) < 256 Then
        HexColor = Hex$(nr)
    Else
        HexColor = "FF"
    End If
    
End Function





