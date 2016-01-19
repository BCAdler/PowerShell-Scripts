This is a program I have been working on for work.  It integrates PowerShell with SCCM so that we can image machines basically 
touchlessly. 

This script remotely reboots machines and has them automatically boot to their network interfaces in order to contact the PXE server and 
boot from the network.  

Note:  This was designed for Dell machines.  The application "forcepxe.exe" was created using Dell's Command and Configure software.  
       Therefore this may not work on other brands of PC's but tweaked to work if the manfacturer has the same type of application
       available to aid in PC management.
