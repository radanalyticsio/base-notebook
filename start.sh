#!/bin/bash

if [[ "x$JUPYTER_NOTEBOOK_PASSWORD" != "x" ]]; then
    HASH=$(python -c "from notebook.auth import passwd; print(passwd('$JUPYTER_NOTEBOOK_PASSWORD'))")
    echo "c.NotebookApp.password = u'$HASH'" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py
fi

export PYTHONPATH=$SPARK_HOME/python:$(echo $SPARK_HOME/python/lib/py4j-*-src.zip)
exec jupyter notebook
