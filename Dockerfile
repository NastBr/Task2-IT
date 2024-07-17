FROM ubuntu:22.04

ENV SOFT "/soft"
ENV HTSLIB "$SOFT/htslib-1.20"
ENV SAMTOOLS "$SOFT/samtools-1.20"
ENV LIBDEFLATE "$SOFT/libdeflate-1.20"

RUN mkdir -p $SOFT
RUN apt-get update && apt-get install -y git wget bzip2 gcc autoconf automake make perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev cmake

# LIBDEFLATE 1.20
RUN cd $SOFT && \
 wget https://github.com/ebiggers/libdeflate/releases/download/v1.20/libdeflate-1.20.tar.gz && \
 tar -xf libdeflate-1.20.tar.gz && \
 rm libdeflate-1.20.tar.gz && \ 
 cd libdeflate-1.20 && \
 cmake -B build && cmake -DCMAKE_PREFIX_PATH=$LIBDEFLATE && cmake --build build

# HTSLIB 1.20
ENV CPPFLAGS "-I$SOFT/libdeflate-1.20/build${CPPFLAGS:+:}$CPPFLAGS"
ENV LDFLAGS "-L$SOFT/libdeflate-1.20/build${LDFLAGS:+:}$LDFLAGS"
ENV C_INCLUDE_PATH "$SOFT/libdeflate-1.20"
ENV LIBRARY_PATH "$SOFT/libdeflate-1.20"

RUN cd $SOFT && \
 wget https://github.com/samtools/htslib/releases/download/1.20/htslib-1.20.tar.bz2 && \
 tar -xjf htslib-1.20.tar.bz2 && \
 rm htslib-1.20.tar.bz2 && \
 cd htslib-1.20 && \
 ./configure --prefix $HTSLIB --with-libdeflate && \
 make && \
 make install
  

# SAMTOOLS 1.20
RUN cd $SOFT && \
 wget https://github.com/samtools/samtools/releases/download/1.20/samtools-1.20.tar.bz2 && \
 tar -xjf samtools-1.20.tar.bz2 && \
 rm samtools-1.20.tar.bz2 && \
 cd samtools-1.20 && \
 ./configure --prefix $SAMTOOLS --with-htslib=$HTSLIB && \
 make && \
 make install

ENV PATH ${PATH}:$HTSLIB:$SAMTOOLS:$LIBDEFLATE

ENV SAMTOOLS "$SAMTOOLS/samtools"

CMD ["bash"] 