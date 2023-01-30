#!/bin/bash
#Script Develop for Ing.Kenny Ortiz

curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash - #  se descarga el repositorion node 16
yum install -y nodejs # se instala node 


# se agrega el contexto Chanspy
cat << 'EOF' >> /etc/asterisk/extensions_override_issabelpbx.conf  

[app-chanspy]
include => app-chanspy-custom
exten => 555,1,NoOp(ChanSpy)
same => n,Authenticate(1234) 
same => n,ChanSpy(${dst},qs${type})
; end of [app-chanspy]
EOF

#se crea credenciales para Ami 
cat << EOF >> /etc/asterisk/manager_custom.conf

[sencom]
secret = 31994
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.0
read = system,call,log,verbose,command,agent,user,config,dtmf,reporting,cdr,dialplan
write = system,call,log,verbose,command,agent,user,config,command,reporting,originate
EOF


asterisk -rx 'core restart now'

mkdir /usr/local/Chanspy

wget https://github.com/kenny2223/Install/blob/main/ChanSpy-1.tar.gz?raw=true -O ChanSpy-1.tar.gz


tar xzvf ChanSpy-1.tar.gz
cp -r ./ChanSpy-1/* /usr/local/Chanspy

rm -rf  ChanSpy-1.tar.gz
rm -rf  ChanSpy-1


cd /usr/local/Chanspy

npm i --only=prod 


# se agrega la applicacion como servicio en systemd 
cat << EOF > /etc/systemd/system/chanspy.service
[Unit]
Description=Chanspy service

[Service]
Type=simple
ExecStart=/usr/bin/node  /usr/local/Chanspy/app.js

[Install]
WantedBy=multi-user.target
EOF


chmod +x /etc/systemd/system/chanspy.service

systemctl enable  chanspy.service && systemctl start chanspy.service

#se finaliza la instalacion

