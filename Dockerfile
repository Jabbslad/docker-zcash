FROM ubuntu
MAINTAINER jabbslad <jabbslad@gmail.com>

ENV ZCASH_VERSION v1.0.0
ENV ZCASH_RPC_USERNAME zcash
ENV ZCASH_CONF_DIR /root/.zcash
ENV ZCASH_CONF ${ZCASH_CONF_DIR}/zcash.conf

RUN apt-get -y update && apt-get -y install \
	build-essential pkg-config libc6-dev m4 g++-multilib \
	autoconf libtool ncurses-dev unzip git python \
	zlib1g-dev wget bsdmainutils automake

RUN git clone https://github.com/zcash/zcash.git && \
	cd zcash/ && \
	git checkout "${ZCASH_VERSION}" && \
	./zcutil/fetch-params.sh

RUN cd zcash/ && ./zcutil/build.sh -j$(nproc)

RUN mkdir -p ${ZCASH_CONF_DIR} && \
	echo "addnode=mainnet.z.cash" > ${ZCASH_CONF} && \
	echo "rpcuser=${ZCASH_RPC_USERNAME}" >> ${ZCASH_CONF} && \
	echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ${ZCASH_CONF} && \
	echo 'gen=1' >> ${ZCASH_CONF} && \
	echo "genproclimit=$(nproc)" >> ${ZCASH_CONF}

ENTRYPOINT ["./zcash/src/zcashd"]