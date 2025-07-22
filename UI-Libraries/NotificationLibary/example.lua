local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/notification_gui_library.lua", true))()

--[[ * For each notification here's the documentation.

Info: Args(<string> Title, <string> Heading, <string> Body, <boolean?> AutoRemoveNotif, <number?> AutoRemoveTime, <function?> OnCloseFunction)

Example: Notification.new("Success", "Heading", "Success body message.", true, 2)

All types of titles that are allowed are,

error, success, info, warning, message (All must be lowercase.)

More Examples:

local notif = Notification.new("success", "Success", "Success body message.")
notif:changeHeading("New Heading") -- Args(<string> NewHeading)
notif:changeBody("New Body") -- Args(<string> NewBody)
notif:deleteTimeout(3) -- Args(<number> DeleteWaitTime)
notif:delete()
]]

-- Test Example

Notification.new("Success", "Heading", "Success body message.", true, 1)
