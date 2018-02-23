FROM python:2.7

# Install system requirements
RUN apt-get update && apt-get install -y \
        build-essential \
        git \
        libxml2-dev \
        libxslt1-dev \
        python-dev \
        python-pip \
        redis-server \
        zlib1g-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/opt/lists/*

WORKDIR /build

# Install RTD
RUN git clone https://github.com/rtfd/readthedocs.org.git && \
    cd readthedocs.org && \
    pip install -r requirements.txt

WORKDIR /build/readthedocs.org

# Do configuration
RUN python manage.py migrate                    && \
    python manage.py createsuperuser            && \
    python manage.py collectstatic --noinput    && \
    python manage.py loaddata test_data         && \
    echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', 'admin')" \
        | python manage.py shell

COPY ./files/local_settings.py /build/readthedocs.org/readthedocs/settings/local_settings.py

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
