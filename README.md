# appmon.ps1
A powershell script aim to capture certain system informaiton on an application that randomly crash in Window 10.

Script Flow:
1. Monitor the process.
2. Logged the local port used by the process when the process is stopped.
3. Start the service.
4. Collect application logs from both AppData and ProgramData.
5. Collect last 5 Window Event log for the current incident.
6. Press any key to stop the monitoring.

Collected logs will be saved in the newly created folder named 'ps_logs' in the Desktop.

To run the script:
1. Open powershell and run as administrator.
2. Enter 'Set-ExecutionPolicy -ExecutionPolicy RemoteSigned'.
3. Execute the script './appmon.ps1'
4. Revert the powershell execution policy to 'Set-ExecutionPolicy -ExecutionPolicy Default'
