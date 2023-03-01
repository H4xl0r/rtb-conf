####################################
#
#  Dockerfile for Root the Box
#  v0.1.3 - By Moloch, ElJeffe

FROM python:latest

RUN mkdir /opt/rtb
ADD . /opt/rtb

RUN apt-get update && apt-get install -y \
build-essential zlib1g-dev rustc \
python3-pycurl sqlite3 libsqlite3-dev openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:rootthebox' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

ADD ./setup/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt --upgrade
RUN wget https://github.com/H4xl0r/rtb-conf/blob/main/rootthebox.cfg -o /opt/rtb/files/rootthebox.cfg
RUN wget https://github.com/H4xl0r/rtb-conf/blob/main/rootthebox.db -o /opt/rtb/files/rootthebox.db

VOLUME ["/opt/rtb/files"]
ENTRYPOINT ["python3", "/opt/rtb/rootthebox.py", "--start"]