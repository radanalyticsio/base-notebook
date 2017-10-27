# (ideally) minimal pyspark/jupyter notebook

FROM radanalyticsio/openshift-spark:2.2-latest

USER root

## taken/adapted from jupyter dockerfiles
# Not essential, but wise to set the lang
# Note: Users with other languages should set this in their derivative image
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8
ENV CONDA_DIR /opt/conda
ENV NB_USER=nbuser
ENV NB_UID=1011
ENV NB_PYTHON_VER=2.7
ENV PATH $CONDA_DIR/bin:$PATH
ENV SPARK_HOME /opt/spark
# TODO remove tini after docker 1.13.1

LABEL io.k8s.description="PySpark Jupyter Notebook." \
      io.k8s.display-name="PySpark Jupyter Notebook." \
      io.openshift.expose-services="8888:http"


RUN echo 'PS1="\u@\h:\w\\$ \[$(tput sgr0)\]"' >> /root/.bashrc \
    && chgrp root /etc/passwd \
    && chgrp -R root /opt \
    && chmod -R ug+rwx /opt \
    && useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
    && usermod -g root $NB_USER \
    && yum install -y curl wget java-headless bzip2 gnupg2 sqlite3 gcc gcc-c++ glibc-devel git mesa-libGL mesa-libGL-devel
    


USER $NB_USER


# Python binary and source dependencies and Development tools

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot. 
# 
ADD fix-permissions.sh /usr/local/bin/fix-permissions.sh
ENV HOME /home/$NB_USER
RUN mkdir $HOME/.jupyter \
    && cd /tmp \
    && wget -q https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh \
    && echo d0c7c71cc5659e54ab51f2005a8d96f3 Miniconda3-4.2.12-Linux-x86_64.sh | md5sum -c - \
    && bash Miniconda3-4.2.12-Linux-x86_64.sh -b -p $CONDA_DIR \
    && rm Miniconda3-4.2.12-Linux-x86_64.sh \
    && export PATH=$CONDA_DIR/bin:$PATH \
    && $CONDA_DIR/bin/conda install --quiet --yes python=$NB_PYTHON_VER 'nomkl' \
                numpy \
                scipy \
                pandas \
                jupyter \
                notebook \
    && $CONDA_DIR/bin/conda remove --quiet --yes --force qt pyqt \
    && $CONDA_DIR/bin/conda clean -tipsy \
    && fix-permissions.sh $CONDA_DIR \
    && fix-permissions.sh $HOME 


USER root

# IPython
EXPOSE 8888
WORKDIR $HOME

#&& chown $NB_UID:root /notebooks
RUN mkdir /notebooks  \
    && mkdir -p $HOME/.jupyter \
    && echo "c.NotebookApp.ip = '*'" >> $HOME/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.notebook_dir = '/notebooks'" >> $HOME/.jupyter/jupyter_notebook_config.py \
    && yum erase -y gcc gcc-c++ glibc-devel \
    && yum clean all -y \
    && rm -rf /root/.npm \
    && rm -rf /root/.cache \
    && rm -rf /root/.config \
    && rm -rf /root/.local \
    && rm -rf /root/tmp \
    && fix-permissions.sh /opt \
    && fix-permissions.sh $CONDA_DIR \
    && fix-permissions.sh /notebooks \
    && fix-permissions.sh $HOME


ADD start.sh /usr/local/bin/start.sh
WORKDIR /notebooks
ENTRYPOINT ["tini", "--"]
CMD ["/entrypoint", "start.sh"]

USER $NB_USER
