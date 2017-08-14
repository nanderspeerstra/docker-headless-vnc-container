# This Dockerfile is used to build an headles vnc image based on Ubuntu

FROM ubuntu:16.04

## Connection ports for controlling the UI:
# VNC port:5901
ENV DISPLAY :1
ENV VNC_PORT 5901
EXPOSE $VNC_PORT

ENV HOME /headless
ENV STARTUPDIR /dockerstartup
WORKDIR $HOME

### Envrionment config
ENV DEBIAN_FRONTEND noninteractive
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1280x1024
ENV VNC_PW vncpassword

### Add all install scripts for further steps
ENV INST_SCRIPTS $HOME/install
ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/ubuntu/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh

### Install xvnc-server
RUN $INST_SCRIPTS/tigervnc.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME


# Now, install LaTeX
RUN apt-get update && apt-get install -y \
	texlive-full \
	texworks

RUN apt-get update && apt-get install -y \
	git

# Go back to non-root user
#USER 1984

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--tail-log"]
