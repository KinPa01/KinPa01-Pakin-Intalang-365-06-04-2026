// src/prisma.ts
import 'dotenv/config';            // ให้ Prisma เห็น DATABASE_URL จาก .env
import { PrismaClient } from '@prisma/client';

// ใช้ global เดิมสำหรับ dev (nodemon reload แล้วไม่สร้าง client ซ้ำ)
const globalForPrisma = globalThis as unknown as {
  prisma?: PrismaClient;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: ['query', 'info', 'warn', 'error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
