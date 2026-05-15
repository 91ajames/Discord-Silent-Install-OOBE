# Discord-Silent-Install-OOBE
Installing Discord after OOBE First Login and moving the Shortcut .inc to All Users (or Modify to Single User) and deleting left over Folder in Start Menu

Place SetupComplete.cmd under "C:\Windows\Setup\Scripts". You would need to create the folder "Scripts".

Place the 2 cmd files under C:\

FirstLoginUser.cmd

- Prevent execution in Audit Mode

- Allow Windows login to settle

- Delete Script + SetupComplete

- Skipped but placed Notepad++

- REG FILE IMPORTS (PowerISO & ClassicShell)

- Classic Shell Part 1 - .reg file added to Registry (Might want to add this after discord, for Sort Name to be achieved in Start Menu)

- Classic Shell Part 2 - to import the XML restore cmd line. (Might want to add this after discord, for Sort Name to be achieved in Start Menu)

- Discord Install and waits for installation complete and waits for the folder and shortcut.lnc to show up in StartMenu.

- The wait time is set to 900 seconds and checks every 2 seconds to locate shortcut.lnc

- Once Discord shortcut.lnc is discovered, moves the shortcut.lnc to All Users and deletes the leftover folder.

- Deletes the left over installation from C:\

- Logs is the only file left.



CompleteSetup.cmd

- Enable Classic Context Menu

- Enable Windows Photo Viewer

- Task Schedule FirstLoginUser.vbs (Guarded) + Self Delete after OOBE.

- Logs is the only file left.
