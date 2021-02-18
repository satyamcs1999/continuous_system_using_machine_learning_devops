if sudo docker ps -a | grep test | grep Exited
then
  threshold=0.8
  x=$(cat /dlcode/nn.py | grep epochs | tr -d -c 0-9)
  accuracy=$(sudo docker container logs test | grep Test | grep accuracy | tr -d -c 0-9 | sed -e "s/\b[0-9]/&./g")
  while (( $(echo "$accuracy < $threshold" | bc -l) ));
  do
    sudo sed -i "s/epochs = $x/epochs = $(($x+10))/g" /dlcode/nn.py
    sudo docker start test
    sudo docker exec -d test python3 /train/nn.py
    while sudo docker ps | grep test
    do
      echo "Running after updation of epochs"
    done
    threshold=0.8
    accuracy=$(sudo docker container logs test | grep Test | grep accuracy | tail -1 | tr -d -c 0-9 | sed -e "s/\b[0-9]/&./g")
   
    x=$((x+10))
  done
fi

cat << EOF > pyscript.py
#!/usr/bin/python
import smtplib, ssl
port = 587 
smtp_server = "smtp.gmail.com"
sender_email = "<Enter sender's email>"
receiver_email = "<Enter receiver's email>"
password = "<Enter sender's password>"
message = """\
Subject: Accuracy Status

Threshold Accuracy Reached!!"""

context = ssl.create_default_context()
with smtplib.SMTP(smtp_server, port) as server:
  server.ehlo()
  server.starttls(context=context)
  server.ehlo()
  server.login(sender_email, password)
  server.sendmail(sender_email, receiver_email, message)
EOF
chmod 755 pyscript.py
python3 ./pyscript.py