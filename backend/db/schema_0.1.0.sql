-- Tabla de Usuarios
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    status VARCHAR(10) CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    key VARCHAR(20) UNIQUE NOT NULL,
    version VARCHAR(20),
    server_domain VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Streams Activos
CREATE TABLE streams (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    stream_key VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('active', 'stopped')) DEFAULT 'active',
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    max_viewers INT DEFAULT 0,
    resolution VARCHAR(20) DEFAULT '1920x1080', -- Resolución específica del stream
    bitrate INT DEFAULT 1000, -- Bitrate específico del stream
    codec VARCHAR(50) DEFAULT 'H264' -- Codec específico del stream
);


-- Tabla de Analíticas en Tiempo Real
CREATE TABLE stream_analytics (
    id SERIAL PRIMARY KEY,
    stream_id INT REFERENCES streams(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bandwidth BIGINT,
    viewers INT,
    bitrate INT,
    resolution VARCHAR(20),
    codec VARCHAR(50)
);

-- Tabla de Configuración del Servidor RTMP
CREATE TABLE server_config (
    id SERIAL PRIMARY KEY,
    max_streams INT DEFAULT 10, -- Número máximo de streams permitidos por usuario
    max_bandwidth BIGINT DEFAULT 100000000, -- Ejemplo: 100 Mbps
    default_resolution VARCHAR(20) DEFAULT '1920x1080',
    allowed_codecs TEXT[] DEFAULT ARRAY['H264', 'AAC'],
    user_id INT REFERENCES users(id) ON DELETE CASCADE -- Relación con el usuario
);

-- Tabla de Historial de Streams Finalizados
CREATE TABLE stream_history (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    stream_key VARCHAR(100),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    total_viewers INT,
    average_bitrate INT,
    max_resolution VARCHAR(20),
    codecs_used TEXT[]
);

-- Tabla de Webhooks para Eventos de Streaming
CREATE TABLE stream_events (
    id SERIAL PRIMARY KEY,
    stream_id INT REFERENCES streams(id) ON DELETE CASCADE,
    event_type VARCHAR(50) CHECK (event_type IN ('on_publish', 'on_play', 'on_done')),
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details JSONB
);
