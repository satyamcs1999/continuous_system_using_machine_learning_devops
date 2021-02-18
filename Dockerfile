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