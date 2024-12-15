FROM python:3.10
LABEL org.opencontainers.image.source=https://github.com/Nathan-Kelo/junia-isen-project-example-api
LABEL org.opencontainers.image.description="Image containing a python API for a school project."
WORKDIR /app

COPY . .

RUN pip install -r requirements.txt
RUN opentelemetry-bootstrap --action=install


EXPOSE 5000

CMD ["opentelemetry-instrument", "python", "app.py"]
