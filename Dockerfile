FROM phadej/ghc:7.8.4
MAINTAINER Oleg Grenrus <oleg.grenrus@iki.fi>

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    freeglut3-dev \
    git \
    libblas-dev \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libdevil-dev \
    libedit-dev \
    libedit2 \
    libfreenect-dev \
    libgd2-xpm-dev \
    libglib2.0-dev \
    libglu1-mesa-dev \
    libgmp-dev \
    libgsl0-dev \
    libgtk2.0-dev \
    libicu-dev \
    libjudy-dev \
    liblapack-dev \
    liblzma-dev \
    libmysqlclient-dev \
    libncurses-dev \
    libnotify-dev \
    libpango1.0-dev \
    libpq-dev \
    libsqlite3-dev \
    libssl-dev \
    libxss-dev \
    libyaml-dev \
    llvm \
    m4 \
    texlive-binaries \
    wget \
    zip \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Nettle http://www.lysator.liu.se/~nisse/nettle/
# TODO: 0.3.0?
RUN mkdir -p /usr/src/nettle
WORKDIR /usr/src/nettle

RUN echo "Install nettle" \
  && curl --silent -O https://ftp.gnu.org/gnu/nettle/nettle-2.7.1.tar.gz \
  && tar --strip-components=1 -xzf nettle-2.7.1.tar.gz \
  && ./configure --prefix=/usr/local \
  && make \
  && make install \
  && rm -rf /usr/src/nettle

# SDL
RUN mkdir -p /usr/src/sdl2
WORKDIR /usr/src/sdl2

RUN echo "Install SDL2" \
  && curl --silent -O https://www.libsdl.org/release/SDL2-2.0.3.tar.gz \
  && tar --strip-components=1 -xzf SDL2-2.0.3.tar.gz \
  && ./configure --prefix=/usr/local \
  && make \
  && make install \
  && rm -rf /usr/src/sdl2

# ZeroMQ
RUN mkdir -p /usr/src/zeromq
WORKDIR /usr/src/zeromq

RUN echo "Install ZeroMQ" \
  && curl --silent -O http://download.zeromq.org/zeromq-4.1.0-rc1.tar.gz \
  && tar --strip-components=1 -xzf zeromq-4.1.0-rc1.tar.gz \
  && ./configure --prefix=/usr/local \
  && make \
  && make install \
  && rm -rf /usr/src/zeromq

# Stackage and hscolour!
WORKDIR /root

RUN cabal update && cabal install hscolour

RUN git clone https://github.com/phadej/stackage.git
WORKDIR /root/stackage

RUN git checkout skip-haddock \
  && cabal configure \
  && cabal install

RUN cabal install hscolour
RUN cp /root/.cabal/bin/stackage /root/.cabal/bin/HsColour /opt/ghc/bin/ \
  && for pkg in `ghc-pkg --user list  --simple-output`; do ghc-pkg unregister --force $pkg; done \
  && rm -rf /root/.cabal \
  && rm -rf /root/stackage \
  && stackage --version

# TODO: unpriviled user for builds

# Done
VOLUME /stackage
WORKDIR /stackage

CMD ["bash"]

