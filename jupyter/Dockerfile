# Build stage
FROM python:3.8-buster AS PyBuilder

WORKDIR /tmp

RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository non-free
RUN apt-get update && apt-get install -y \
  build-essential \
  wget \
  libopenblas-base \
  libopenblas-dev \
  liblapack-dev

WORKDIR /wheels
RUN pip wheel \
  jupyter \
  jupyterlab \
  pandas \
  numpy \
  elasticsearch \
  kafka \
  redis \
  matplotlib \
  cassandra-driver

#RUN go get -u github.com/gopherdata/gophernotes
#RUN mkdir -p ~/.local/share/jupyter/kernels/gophernotes
#RUN cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* ~/.local/share/jupyter/kernels/gophernotes

FROM python:3.8-buster

ENV user=jupyter
ENV uid=61000
ENV home=/notebooks

COPY --from=PyBuilder /wheels /wheels 
#RUN apt-get update && apt-get install -y libopenblas-base && apt-get -y autoremove && apt-get autoclean && apt-get clean
RUN pip install \
  jupyter \
  jupyterlab \
  pandas \
  numpy \
  elasticsearch \
  kafka \
  redis \
  matplotlib \
  cassandra-driver \
  -U -f wheels && rm -rf /wheels && rm -rf /root/.cache/pip

RUN useradd -ms /bin/false -d $home $user && usermod -u $uid $user
USER $user
WORKDIR $home

ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0"]
