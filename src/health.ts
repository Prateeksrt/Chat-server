import { Request, Response } from 'express';

export const healthCheck = (req: Request, res: Response): void => {
  const healthData = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0',
    memory: process.memoryUsage(),
  };

  res.status(200).json(healthData);
};

// Standalone health check for Docker
if (require.main === module) {
  const http = require('http');
  const options = {
    hostname: 'localhost',
    port: process.env.PORT || 3000,
    path: '/health',
    method: 'GET',
    timeout: 2000,
  };

  const req = http.request(options, (res: any) => {
    if (res.statusCode === 200) {
      process.exit(0);
    } else {
      process.exit(1);
    }
  });

  req.on('error', () => {
    process.exit(1);
  });

  req.on('timeout', () => {
    req.destroy();
    process.exit(1);
  });

  req.end();
}