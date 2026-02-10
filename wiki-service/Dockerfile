FROM python:3.13-slim

WORKDIR /app

COPY pyproject.toml .
RUN pip install --upgrade pip setuptools wheel && pip install --upgrade build && python -m build --wheel --outdir dist && pip install dist/*.whl

COPY ./app ./app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]