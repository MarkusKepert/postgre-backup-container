FROM alpine:3.10

ENV PGHOST='localhost'
ENV PGPORT='5432'
ENV PGDATABASE='postgres'
ENV PGUSER='postgres@postgres'
ENV PGPASSWORD='password'

ENV S3_URL=''
ENV S3_KEY=''
ENV S3_SECRET=''
ENV S3_BUCKET='backup'

RUN apk update
RUN apk add postgresql
RUN apk add --no-cache ca-certificates
RUN apk add curl
RUN curl -O https://dl.minio.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc
RUN cp mc /usr/local/bin/

COPY dumpDatabase.sh .

ENTRYPOINT [ "/bin/sh" ]
CMD [ "./dumpDatabase.sh" ]