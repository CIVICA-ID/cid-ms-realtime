import { registerAs } from '@nestjs/config';

export default registerAs('database', () => ({
  // Master connection (for WRITES)
  master: {
    host: process.env.DATABASE_HOST || 'localhost',
    port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
    username: process.env.DATABASE_USER || 'civicaid_user',
    password: process.env.DATABASE_PASSWORD || 'civicaid_secure_password',
    database: process.env.DATABASE_NAME || 'civicaid_db',
  },
  // Slave/Replica connection (for READS)
  replica: {
    host: process.env.DATABASE_REPLICA_HOST || process.env.DATABASE_HOST || 'localhost',
    port: parseInt(process.env.DATABASE_REPLICA_PORT, 10) || parseInt(process.env.DATABASE_PORT, 10) || 5432,
    username: process.env.DATABASE_USER || 'civicaid_user',
    password: process.env.DATABASE_PASSWORD || 'civicaid_secure_password',
    database: process.env.DATABASE_NAME || 'civicaid_db',
  },
  // Common settings
  schema: 'realtime',
  synchronize: process.env.NODE_ENV !== 'production',
  logging: process.env.NODE_ENV === 'development',
  ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
}));
