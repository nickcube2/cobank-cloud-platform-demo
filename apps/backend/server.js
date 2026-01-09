/**
 * CoBank Demo Backend (Express)
 *
 * Goals:
 * - Single runtime (Node) and single port (3000 by default)
 * - Health + readiness endpoints for Kubernetes
 * - Basic structured logging and error handling
 */

const express = require('express');

const app = express();
const PORT = Number(process.env.PORT || 3000);
const SERVICE_NAME = process.env.SERVICE_NAME || 'cobank-backend';
const SERVICE_VERSION = process.env.SERVICE_VERSION || '1.0.0';

// Trust proxy to get correct client IP behind ingress/load balancers.
app.set('trust proxy', true);

app.use(express.json({ limit: '1mb' }));

// Request logger (simple JSON line)
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - start;
    const log = {
      ts: new Date().toISOString(),
      level: 'info',
      service: SERVICE_NAME,
      method: req.method,
      path: req.originalUrl,
      status: res.statusCode,
      duration_ms: ms,
      ip: req.ip,
      user_agent: req.get('user-agent'),
    };
    // eslint-disable-next-line no-console
    console.log(JSON.stringify(log));
  });
  next();
});

// Liveness: process is up.
app.get('/api/live', (_req, res) => {
  res.status(200).json({ status: 'live', ts: new Date().toISOString() });
});

// Readiness: app is ready to serve.
// (If you later add dependencies like DB/queues, check them here.)
app.get('/api/ready', (_req, res) => {
  res.status(200).json({ status: 'ready', ts: new Date().toISOString() });
});

// Backwards-compatible "health" endpoint
app.get('/api/health', (_req, res) => {
  res.status(200).json({ status: 'healthy', ts: new Date().toISOString() });
});

app.get('/api/info', (_req, res) => {
  res.status(200).json({ service: SERVICE_NAME, version: SERVICE_VERSION });
});

// Example business endpoint
app.get('/api/message', (_req, res) => {
  res.status(200).json({
    message: 'Hello from CoBank backend 👋',
    ts: new Date().toISOString(),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.originalUrl,
  });
});

// Error handler
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  // eslint-disable-next-line no-console
  console.error(JSON.stringify({
    ts: new Date().toISOString(),
    level: 'error',
    service: SERVICE_NAME,
    message: err?.message || 'Unhandled error',
    stack: err?.stack,
  }));
  res.status(500).json({ error: 'Internal Server Error' });
});

app.listen(PORT, '0.0.0.0', () => {
  // eslint-disable-next-line no-console
  console.log(JSON.stringify({
    ts: new Date().toISOString(),
    level: 'info',
    service: SERVICE_NAME,
    message: `Listening on :${PORT}`,
  }));
});
