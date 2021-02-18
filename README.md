__<h1>Building a Continuous System using Machine Learning and DevOps</h1>__

![MLOps](https://miro.medium.com/max/875/1*xcJe61a8WKT1Fn4k3x_q2w.jpeg)<br><br>

<h2>Why 60% of Machine Learning Projects are never implemented?</h2>
<p>The major reason behind the scene is the manual work behind the scene, and this is due to Hyperparameters. <b>Hyperparameters</b> are those parameters whose values are set before the learning process begins, and it needs to be specified manually , unlike Model Parameters , which are training set properties that learn on its own during training by ML model.</p><br>
<p>Hyperparameters are important as they affect the behavior of the training algorithm , also they have an important impact on performance of model under training. Hyperparameters are deciders in this regards and needs to be set up judiciously. It could be of great hindrance to the concept of automation , which we can’t imagine life without in this world.</p><br>
<p>So, to rectify this , an automation system could be developed that could tweak the values of the same so as to improve the accuracy and it is possible by integrating Machine Learning with DevOps tools like <b>Git</b> and <b>Jenkins</b>.</p><br>
<p>Since there are multiple parts for the same , let’s understand each part one by one.</p><br>

<h2>Part 1 : Setting up Dockerfile for creating Docker Image for Machine Learning</h2>

<p>For facilitating the execution of ML Code inside a Docker container , Docker image with required libraries could be created using <b>Dockerfile</b>.</p><br>
<p>The Dockerfile created in this case is as follows :</p><br>

```dockerfile
FROM centos

RUN yum install python3 -y

RUN yum install curl -y

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"

RUN python3 get-pip.py

RUN pip3 install -U pip setuptools

RUN pip3 install tensorflow-cpu

RUN pip3 install numpy

RUN pip3 install pillow

RUN pip3 install keras

RUN pip3 install pandas

COPY . /train

CMD python3 /train/nn.py
```

<br>
<p>Image created from the same has all the setup mentioned here and the one mentioned with <b>COPY</b> and <b>CMD</b> is executed after the container is created from the image generated.</p><br><br>

<h2>Part 2 : GitHub Setup</h2>

<p>In this job, the developer pushes the code into <b>GitHub</b></p><br>
<p>Initially , we have to set up our local repository in our respective local machine and it could be set up using <b>Git Bash</b>, in our case , we have set up folder named <b>“ml_code”</b> holding the program files. The commands to set up the same are as follows :</p><br>

```
mkdir ml_code/

cd ml_code/

vim nn.py   # you can use notepad or any other text editor
```

<br>
<p>Before creating our own local repository , we first need to create an empty repository in GitHub , after creating , convert the existing directory i.e,<b>ml_code</b> and push the program file <b>“nn.py”</b> to the GitHub Repository using the following commands :</p><br>

```
git init                                

git add * 

git commit -m "CNN"

git remote add origin https://github.com/satyamcs1999/MLOps.git

git push -u origin main
```

<br>
<p>For pushing the program files to our master branch in GitHub repository , we need to specify <b>“git push -u origin main</b>(only during first time) or <b>git push</b>”, but by using the <b>hooks/</b> directory within <b>.git/</b>, we can modify it in such a way that it would commit and also push without specifying any separate command for the same, first of all we need to create a file named <b>“post-commit”</b> and script to be included are as follows :</p><br>

```
vim post-commit

#!/bin/bash

git push
```

<br>
<p>After this setup , GitHub would look like this:</p><br>

![GitHub](https://miro.medium.com/max/875/1*jo9R7QddpgqBasTbgs5MPA.png)<br><br>

<p><b>Note:</b> The link to the GitHub repository mentioned above is at the bottom of this README</p><br>
<br>
<h2>Part 3 : Jenkins Jobs</h2>

<p><b>Job 1</b> : This job first pulls the code as soon as Jenkins detect changes in connected GitHub repo.</p><br>

<h3>Setting up Webhook using ngrok</h3>

![Webhook_ngrok_1](https://miro.medium.com/max/875/1*oqW07U48Z9sa6a1Ya3kYXQ.png)<br>

![Webhook_ngrok_2](https://miro.medium.com/max/875/1*dqwhwLbRkT6e6fCk_GZn-w.png)<br>

<p>The triggers we use are GitHub hook triggers that could be setup by adding a webhook to our GitHub repo , and for creating webhook in our repo , we need a public URL that could be generated by using <b>ngrok</b>, which uses the concept of <b>Tunneling</b>.</p><br>

```
./ngrok http 8080
```

![Webhook_ngrok_3](https://miro.medium.com/max/875/1*lHHWjpUEkiMzOku_Xo_amQ.png)<br>

<p align="center"><b>Setting up Public URL using ngrok</b></p><br>

![Webhook_ngrok_4](https://miro.medium.com/max/875/1*bX67d4-VfI74yllkjECLLg.png)<br>

<p align="center"><b>Addition of Webhook</b></p><br><br>

![Job1_Code](https://cdn-images-1.medium.com/max/1000/1*miwgNgFrnYXaT_fPp_R6ug.png)<br>

<p align="center"><b>Job 1</b></p><br>

<p>The code above tests the presence of directory called <b>dlcode</b>, if present , the code from the GitHub repo is copied to dlcode directory , if no, it first creates it and then do the same process. This job is an upstream project for Job 2.</p><br><br>

<p><b>Job 2</b> : This job mounts the code present in dlcode directory to the train directory inside the container created and starts executing that code, after which it checks for <b>accuracy</b> and compares it the threshold specified , if satisfied , it sends an email stating that the <b>"Threshold Accuracy Reached!!!"</b> and prematurely exits the <b>Jenkins pipeline</b> using exit 1 or else moves on to Job 3, thereby acts as an upstream project for Job 3 and downstream project for Job 1 .</p><br>

![Job2_Code](https://cdn-images-1.medium.com/max/1000/1*UGJ8yz4Mr9I6HUYT7FX_Yw.png)<br>

<p align="center"><b>Job 2</b></p><br><br>

<p><b>Job 3</b> : This job runs if the threshold is not satisfied by the <b>accuracy</b> in the previous job , first it checks if the container is stopped and then it checks for the accuracy, if it doesn't satisfy the threshold , the <b>no. of epochs</b> are tweaked and increased by 10 , and then execution is performed , after which it's accuracy is checked , this process takes place till the accuracy is greater than threshold and after it happens , a mail is sent to the developer stating <b>"Threshold Accuracy Reached!!!"</b> and the overall process gets completed.</p><br>
<p>It is a downstream project for Job 2</p><br>

![Job3_Code_1](https://cdn-images-1.medium.com/max/1000/1*Eo3SocmQ_ORmlpA3tC_mMg.png)<br>

<p align="center"><b>Job 3 : Part 1</b></p><br>

![Job3_Code_2](https://cdn-images-1.medium.com/max/1000/1*ROklHX_LG936I28HmytxHQ.png)<br>

<p align="center"><b>Job 3 : Part 2</b></p><br><br>

<h2>Email received after successful execution of process</h2>

![Email](https://cdn-images-1.medium.com/max/1000/1*4DQJeNoDK7eIC4iAIKPmcQ.png)<br><br>

<h2>Thank You :smiley:<h2>
<h3>LinkedIn Profile</h3>
https://www.linkedin.com/in/satyam-singh-95a266182

<h2>Link to the repository mentioned above</h2>
https://github.com/satyamcs1999/MLOps.git
