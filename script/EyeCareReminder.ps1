# Get the current user's Documents folder path
$userProfile = [System.Environment]::GetFolderPath("MyDocuments")
$logDirectory = Join-Path -Path $userProfile -ChildPath "EyeCareReminder"

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory | Out-Null
}

# Set the log file path
$logFile = Join-Path -Path $logDirectory -ChildPath "log.txt"

# Log script start event
Add-Content $logFile "Script started at: $(Get-Date)"

# Initialize a variable to track first run
$firstRun = $true

while ($true) {
    if ($firstRun) {
        # First-time notification (welcome message)
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
        $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)

        $textNodes = $xml.GetElementsByTagName("text")
        $textNodes.Item(0).AppendChild($xml.CreateTextNode("Welcome to Eye Care Reminder!")) | Out-Null
        $textNodes.Item(1).AppendChild($xml.CreateTextNode("This program will remind you to take a break every 20 minutes.")) | Out-Null

        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Eye Care Reminder")
        $notifier.Show($toast)

        # Log welcome message event
        Add-Content $logFile "Welcome message shown at: $(Get-Date)"

        # Set firstRun to false so this notification doesn't show again
        $firstRun = $false

        # Wait for 20 minutes before the first reminder
        Start-Sleep -Seconds 1200
    } else {
        # Regular look away notification (after 20 minutes)
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
        $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
        
        $textNodes = $xml.GetElementsByTagName("text")
        $textNodes.Item(0).AppendChild($xml.CreateTextNode("20-Minute Break Reminder")) | Out-Null
        $textNodes.Item(1).AppendChild($xml.CreateTextNode("Look away from the screen for 20 seconds!")) | Out-Null

        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Eye Care Reminder")
        $notifier.Show($toast)

        # Log look away notification event
        Add-Content $logFile "Look away notification sent at: $(Get-Date)"

        # Sleep for 20 seconds (look away)
        Start-Sleep -Seconds 20

        # Look back notification
        $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
        $textNodes = $xml.GetElementsByTagName("text")
        $textNodes.Item(0).AppendChild($xml.CreateTextNode("Back to Work")) | Out-Null
        $textNodes.Item(1).AppendChild($xml.CreateTextNode("You can now look back at the screen.")) | Out-Null

        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        $notifier.Show($toast)

        # Log look back notification event
        Add-Content $logFile "Look back notification sent at: $(Get-Date)"

        # Sleep for 20 minutes before the next reminder
        Start-Sleep -Seconds 1200
    }
}
