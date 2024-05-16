FROM public.ecr.aws/docker/library/postgres:16-alpine

#Install python and pip
RUN echo "**** install Python and pip ****" && \
    apk add --update --no-cache python3 py3-pip py3-setuptools py3-wheel

COPY requirements.txt .

RUN pip install --upgrade --no-cache-dir --break-system-packages -r requirements.txt

COPY backup.py .

ENTRYPOINT ["./backup.py"]

