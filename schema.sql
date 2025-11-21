-- schema.sql
-- Run in Postgres with PostGIS extension enabled

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (riders & drivers)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone VARCHAR(32) UNIQUE NOT NULL,
  name VARCHAR(200),
  email VARCHAR(200),
  role VARCHAR(20) DEFAULT 'rider', -- rider | driver | admin
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Driver profiles
CREATE TABLE IF NOT EXISTS drivers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  vehicle_registration VARCHAR(64),
  vehicle_type VARCHAR(32),
  rating NUMERIC(3,2) DEFAULT 0,
  documents JSONB,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Vehicles (optional multiple per driver)
CREATE TABLE IF NOT EXISTS vehicles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  registration VARCHAR(64),
  type VARCHAR(32),
  capacity INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Places (saved)
CREATE TABLE IF NOT EXISTS places (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100),
  address VARCHAR(400),
  geom GEOMETRY(POINT, 4326),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Rides
CREATE TABLE IF NOT EXISTS rides (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rider_id UUID REFERENCES users(id) ON DELETE SET NULL,
  driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
  status VARCHAR(32) DEFAULT 'requested', -- requested, assigned, en-route, completed, cancelled
  origin_address VARCHAR(400),
  destination_address VARCHAR(400),
  origin_geom GEOMETRY(POINT, 4326),
  destination_geom GEOMETRY(POINT, 4326),
  distance_meters INTEGER,
  duration_seconds INTEGER,
  price_cents BIGINT,
  surge_multiplier NUMERIC(4,2) DEFAULT 1.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Payments
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ride_id UUID REFERENCES rides(id) ON DELETE CASCADE,
  amount_cents BIGINT NOT NULL,
  currency VARCHAR(8) DEFAULT 'KES',
  method VARCHAR(64),
  status VARCHAR(32) DEFAULT 'pending',
  gateway_response JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Wallets
CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  balance_cents BIGINT DEFAULT 0,
  currency VARCHAR(8) DEFAULT 'KES',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Audit logs
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID,
  action VARCHAR(200),
  object_type VARCHAR(100),
  object_id UUID,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes for geo
CREATE INDEX IF NOT EXISTS idx_places_geom ON places USING GIST (geom);
CREATE INDEX IF NOT EXISTS idx_rides_origin_geom ON rides USING GIST (origin_geom);

-- Seed admin user (optional)
INSERT INTO users (id, phone, name, role) VALUES ('00000000-0000-0000-0000-000000000001', '+254700000000', 'Admin', 'admin')
ON CONFLICT (id) DO NOTHING;