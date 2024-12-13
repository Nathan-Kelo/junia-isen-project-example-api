FROM python:3.10
LABEL org.opencontainers.image.source=https://github.com/Nathan-Kelo/junia-isen-project-example-api
LABEL org.opencontainers.image.description="Image containing a python API for a school project."
WORKDIR /app

COPY . .

RUN pip install -r requirements.txt
RUN opentelemetry-bootstrap --action=install

# Set environment variables for OpenTelemetry
ENV OTEL_RESOURCE_ATTRIBUTES=service.name=cloudcomputing
ENV OTEL_EXPORTER_OTLP_ENDPOINT=https://ingest.eu.signoz.cloud:443
ENV OTEL_EXPORTER_OTLP_HEADERS=signoz-access-token=ec09f832-ea7e-4842-8e1d-37099cf53402
ENV OTEL_EXPORTER_OTLP_PROTOCOL=grpc

EXPOSE 5000

CMD ["opentelemetry-instrument", "python", "app.py"]
