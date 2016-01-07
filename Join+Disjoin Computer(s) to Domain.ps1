#PowerShell 3

#Join Computer to Domain
Add-Computer -ComputerName Client-PC -DomainName demo -OUPath "OU=Servers,DC=,DC=test,DC=lan" -Credential demo\jeffwouters -Restart 

#Disjoin Computer from Domain
Add-Computer –ComputerName Client-PC –Domain demo –LocalCredential test\jeffwouters –UnjoinDomainCredential test\jefwou –Credential demo\jeffwouters –Restart

#Disjoin Multiple Computers from Domain
Add-Computer –ComputerName Client-PC, Client-PC1, Client-PC2, Client-PC3 –Domain demo –LocalCredential test\jeffwouters –UnjoinDomainCredential test\jefwou –Credential demo\jeffwouters –Restart
