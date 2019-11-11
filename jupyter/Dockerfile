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
  graphviz \
  cassandra-driver

FROM golang:1.13-buster AS GoBuilder

RUN apt-get update && apt-get install -y libczmq-dev
RUN go get -u github.com/gopherdata/gophernotes
RUN mkdir /build /binaries
RUN cp /go/src/github.com/gopherdata/gophernotes/kernel/* /build/
RUN cp /go/bin/gophernotes /binaries

FROM debian:buster AS JuliaBuilder

RUN apt-get update && apt-get install -y wget
RUN mkdir /stuff
WORKDIR /stuff
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.2/julia-1.2.0-linux-x86_64.tar.gz
RUN tar -xzf julia-1.2.0-linux-x86_64.tar.gz

FROM python:3.8-buster

ENV user=jupyter
ENV uid=61000
ENV home=/home/$user
ENV work=/data/
ENV PASSWORD=jupyter

COPY --from=PyBuilder /wheels /wheels 
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
  graphviz \
  -U -f wheels && rm -rf /wheels && rm -rf /root/.cache/pip

RUN apt-get update \
  && apt-get install -y libczmq4 git graphviz \
  && apt-get -y autoremove \
  && apt-get autoclean \
  && apt-get clean

RUN useradd -ms /bin/false -d $home $user && usermod -u $uid -s /bin/bash $user

RUN mkdir -p /home/$user/.local/share/jupyter/kernels/gophernotes
COPY --from=GoBuilder /build /home/$user/.local/share/jupyter/kernels/gophernotes
COPY --from=GoBuilder /binaries/gophernotes /usr/bin

COPY --from=JuliaBuilder /stuff/julia-1.2.0/ $home/.local/julia

RUN chown -R $user /home/$user
RUN mkdir -p $work/notebooks $work/dump $work/pickles && chown -R $user $work && chown -R $user $home
USER $user
RUN mkdir $home/.jupyter
COPY jupyter_notebook_config.py $home/.jupyter/jupyter_notebook_config.py
RUN python3 -c "from notebook.auth.security import set_password; set_password(password=\"${PASSWORD}\")"

RUN mkdir -p ~/.local/bin
ENV PATH "${home}/.local/bin:${home}/.local/julia/bin:$PATH"

RUN julia -e 'using Pkg; Pkg.add("IJulia");'
RUN julia -e 'using Pkg; Pkg.add("DataFrames");'
RUN julia -e 'using Pkg; Pkg.add("JSON");'
RUN julia -e 'using Pkg; Pkg.add("HTTP");'
RUN julia -e 'using Pkg; Pkg.add("Clustering");'
RUN julia -e 'using Pkg; Pkg.add("Plots");'

VOLUME $home/.julia/

WORKDIR $work/notebooks

ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0"]
