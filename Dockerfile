FROM python:3.11-slim AS builder
WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 && rm -rf /var/lib/apt/lists/* \
    && addgroup --gid 1001 appgroup \
    && adduser --uid 1001 --gid 1001 --disabled-password --gecos "" appuser
COPY --from=builder /opt/venv /opt/venv
COPY --chown=appuser:appgroup ./alembic ./alembic
COPY --chown=0:0 --chmod=0444 ./alembic.ini ./alembic.ini
COPY --chown=appuser:appgroup ./app ./app
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app
USER appuser
EXPOSE 8010
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8010"]
