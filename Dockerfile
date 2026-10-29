FROM python:3.12-slim
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
WORKDIR /srv
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
ARG APP_VERSION=dev
ENV APP_VERSION=$APP_VERSION
# run as a normal user, not root
RUN useradd --system --uid 10001 apex
USER 10001
EXPOSE 8000
HEALTHCHECK --interval=15s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request as u; u.urlopen('http://localhost:8000/healthz', timeout=2)"
CMD ["gunicorn", "-b", "0.0.0.0:8000", "-w", "2", "wsgi:app"]
