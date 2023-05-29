import uiautomation as ui
s = ui.ButtonControl(searchDepth=2,Name="スタート")
s.GetInvokePattern().Invoke()