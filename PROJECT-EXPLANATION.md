# คำอธิบายการทำงานของโปรเจกต์ Proxy Server

## 📋 ภาพรวมโปรเจกต์

โปรเจกต์นี้เป็น **Full-Stack Web Application** ที่ประกอบด้วย:
- **Backend**: Express.js + TypeScript + Prisma ORM + PostgreSQL (Supabase)
- **Frontend**: Quasar Framework (Vue.js 3)
- **Containerization**: Docker + Docker Compose
- **Database**: PostgreSQL บน Supabase

## 🏗️ สถาปัตยกรรมระบบ

```mermaid
graph TB
    User[ผู้ใช้งาน] -->|http://localhost:8080| Frontend[Frontend Container<br/>Quasar + Nginx<br/>Port 8080]
    Frontend -->|API Calls| Backend[Backend Container<br/>Express + TypeScript<br/>Port 3000]
    Backend -->|Prisma ORM| Database[(Supabase PostgreSQL<br/>Cloud Database)]
    Backend -->|Volume Mount| Logs[/app/logs<br/>Access Logs]
    
    style Frontend fill:#42b983
    style Backend fill:#68a063
    style Database fill:#336791
    style Logs fill:#ffa500
```

---

## 🔧 โครงสร้างโปรเจกต์

```
ch3.1-proxy-server-main/
├── backend/                    # Backend API Server
│   ├── src/
│   │   ├── server.ts          # Entry point ของ backend
│   │   ├── prisma.ts          # Prisma Client configuration
│   │   └── routes/
│   │       └── task.routes.ts # CRUD API endpoints สำหรับ Task
│   ├── prisma/
│   │   ├── schema.prisma      # Database schema definition
│   │   └── migrations/        # Database migrations
│   ├── Dockerfile             # Multi-stage Docker build
│   ├── package.json           # Dependencies และ scripts
│   └── .env                   # Environment variables (DATABASE_URL)
│
├── frontend/                   # Frontend Web Application
│   ├── src/
│   │   ├── pages/
│   │   │   └── IndexPage.vue  # หน้าแสดงรายการ Task
│   │   ├── layouts/           # Layout components
│   │   ├── router/            # Vue Router configuration
│   │   └── App.vue            # Root component
│   ├── Dockerfile             # Multi-stage Docker build
│   ├── nginx.conf             # Nginx configuration
│   ├── quasar.config.js       # Quasar framework config
│   └── package.json           # Dependencies และ scripts
│
└── docker-compose.yml          # Orchestration configuration
```

---

## 🎯 ส่วนประกอบหลักและการทำงาน

### 1. **Backend (Express + TypeScript + Prisma)**

#### 📄 [server.ts](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/src/server.ts)

**หน้าที่**: Entry point ของ backend server

**การทำงาน**:
```typescript
// 1. Import dependencies
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

// 2. สร้าง Express app
const app = express();
const PORT = process.env.PORT || 3000;

// 3. Middleware
app.use(cors());           // อนุญาต cross-origin requests จาก frontend
app.use(helmet());         // Security headers
app.use(morgan('dev'));    // HTTP request logging
app.use(express.json());   // Parse JSON request body

// 4. Routes
app.get('/api/demo', ...)      // Demo endpoint (Lab 1.2)
app.get('/', ...)              // Health check
app.use('/api/tasks', taskRoutes)  // Task CRUD API
```

**Endpoints ที่มี**:
- `GET /` - Health check endpoint
- `GET /api/demo` - Demo endpoint ที่แสดงข้อมูล Git/Docker และบันทึก log
- `GET /api/tasks` - ดึงรายการ Task ทั้งหมด
- `POST /api/tasks` - สร้าง Task ใหม่
- `GET /api/tasks/:id` - ดึงข้อมูล Task ตาม ID
- `PATCH /api/tasks/:id` - อัปเดต Task
- `DELETE /api/tasks/:id` - ลบ Task

---

#### 📄 [task.routes.ts](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/src/routes/task.routes.ts)

**หน้าที่**: จัดการ CRUD operations สำหรับ Task

**การทำงาน**:

1. **CREATE** (POST `/api/tasks`)
```typescript
router.post('/', async (req, res) => {
  const { title, description } = req.body;
  const task = await prisma.task.create({
    data: { title, description }
  });
  res.status(201).json({ data: task });
});
```

2. **READ ALL** (GET `/api/tasks`)
```typescript
router.get('/', async (_req, res) => {
  const tasks = await prisma.task.findMany({
    orderBy: { createdAt: 'desc' }
  });
  res.json({ data: tasks });
});
```

3. **READ ONE** (GET `/api/tasks/:id`)
4. **UPDATE** (PATCH `/api/tasks/:id`)
5. **DELETE** (DELETE `/api/tasks/:id`)

---

#### 📄 [prisma.ts](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/src/prisma.ts)

**หน้าที่**: สร้างและ export Prisma Client สำหรับเชื่อมต่อ database

**การทำงาน**:
```typescript
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

// สร้าง adapter สำหรับ PostgreSQL
const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!
});

// สร้าง Prisma Client
export const prisma = new PrismaClient({
  adapter,
  log: ['query', 'info', 'warn', 'error']
});
```

**จุดสำคัญ**:
- ใช้ `@prisma/adapter-pg` สำหรับเชื่อมต่อ PostgreSQL
- อ่าน `DATABASE_URL` จาก environment variable
- Enable logging สำหรับ debugging

---

#### 📄 [schema.prisma](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/prisma/schema.prisma)

**หน้าที่**: กำหนด database schema

```prisma
model Task {
  id          String   @id @default(uuid())
  title       String
  description String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  @@map("tasks")
}
```

**โครงสร้างตาราง `tasks`**:
- `id`: UUID (Primary Key)
- `title`: ชื่อ Task (required)
- `description`: รายละเอียด (optional)
- `createdAt`: วันที่สร้าง (auto-generated)
- `updatedAt`: วันที่อัปเดต (auto-updated)

---

#### 📄 [Backend Dockerfile](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/Dockerfile)

**หน้าที่**: สร้าง Docker image สำหรับ backend

**Multi-stage Build**:

**Stage 1: Builder**
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci                          # Install all dependencies
COPY . .
RUN DATABASE_URL="..." npx prisma generate  # Generate Prisma Client
RUN npm run build                   # Compile TypeScript → dist/
```

**Stage 2: Production**
```dockerfile
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
RUN mkdir -p /app/logs && chown -R node:node /app
USER node
COPY package*.json ./
RUN npm ci --only=production        # Install only production deps
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

HEALTHCHECK CMD wget --spider http://localhost:3000/api/demo || exit 1
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**จุดสำคัญ**:
- ใช้ multi-stage build เพื่อลดขนาด image
- Copy Prisma Client ที่ generate แล้วจาก builder stage
- มี healthcheck สำหรับตรวจสอบสถานะ service
- Run ด้วย non-root user (`node`)

---

### 2. **Frontend (Quasar + Vue.js 3)**

#### 📄 [IndexPage.vue](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/frontend/src/pages/IndexPage.vue)

**หน้าที่**: หน้าแสดงรายการ Task

**การทำงาน**:

```vue
<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const API_URL = process.env.API_URL || 'http://localhost:3000';
const tasks = ref([]);
const loading = ref(false);
const errorMessage = ref('');

const fetchTasks = async () => {
  loading.value = true;
  try {
    const res = await axios.get(API_URL + '/api/tasks');
    tasks.value = res.data.data;
  } catch (err) {
    errorMessage.value = 'โหลดงานจากฐานข้อมูลไม่สำเร็จ';
  } finally {
    loading.value = false;
  }
};

onMounted(fetchTasks);
</script>
```

**Template**:
- แสดงปุ่ม "Reload Tasks" พร้อม loading state
- แสดง error message ถ้ามี
- แสดงรายการ Task ใน `q-list` component
- แสดงข้อความ "ยังไม่มีงานในระบบ" ถ้าไม่มีข้อมูล

---

#### 📄 [Frontend Dockerfile](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/frontend/Dockerfile)

**Multi-stage Build**:

**Stage 1: Builder**
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps --ignore-scripts
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN npx quasar build               # Build SPA → dist/spa/
```

**Stage 2: Production (Nginx)**
```dockerfile
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist/spa /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**จุดสำคัญ**:
- Build Quasar SPA ใน builder stage
- Serve static files ด้วย Nginx
- รับ `VITE_API_URL` เป็น build argument

---

### 3. **Docker Compose Orchestration**

#### 📄 [docker-compose.yml](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/docker-compose.yml)

**หน้าที่**: จัดการ multi-container application

```yaml
version: '3.9'

services:
  frontend:
    build:
      context: ./frontend
      args:
        VITE_API_URL: http://localhost:3000
    ports:
      - "8080:80"
    depends_on:
      backend:
        condition: service_healthy    # รอให้ backend พร้อมก่อน
    networks:
      - app-network
    restart: unless-stopped

  backend:
    build:
      context: ./backend
    ports:
      - "3000:3000"
    env_file:
      - ./backend/.env
    volumes:
      - ./backend/logs:/app/logs      # Persist logs
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3000/api/demo"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  app-network:                        # Internal network
```

**จุดสำคัญ**:
- Frontend รอให้ backend ผ่าน healthcheck ก่อนจะ start
- ใช้ shared network (`app-network`) สำหรับสื่อสารระหว่าง containers
- Mount volume สำหรับเก็บ logs
- Auto-restart containers เมื่อมีปัญหา

---

## 🔄 Flow การทำงานของระบบ

### 1. **User Request Flow**

```mermaid
sequenceDiagram
    participant User
    participant Browser
    participant Nginx
    participant Frontend
    participant Backend
    participant Prisma
    participant Database

    User->>Browser: เปิด http://localhost:8080
    Browser->>Nginx: GET /
    Nginx->>Browser: Return index.html + JS bundles
    Browser->>Frontend: Load Vue.js App
    Frontend->>Frontend: onMounted() triggered
    Frontend->>Backend: GET http://localhost:3000/api/tasks
    Backend->>Prisma: prisma.task.findMany()
    Prisma->>Database: SELECT * FROM tasks ORDER BY createdAt DESC
    Database->>Prisma: Return rows
    Prisma->>Backend: Return Task[]
    Backend->>Frontend: JSON { data: [...] }
    Frontend->>Browser: Render task list
    Browser->>User: Display tasks
```

### 2. **Docker Startup Flow**

```mermaid
graph TD
    A[docker-compose up] --> B[Build backend image]
    A --> C[Build frontend image]
    B --> D[Start backend container]
    D --> E{Healthcheck<br/>every 30s}
    E -->|Pass| F[Backend ready]
    E -->|Fail| G[Retry 3 times]
    G --> E
    F --> H[Start frontend container]
    C --> H
    H --> I[Frontend ready]
    I --> J[System ready]
    
    style F fill:#90EE90
    style I fill:#90EE90
    style J fill:#32CD32
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE tasks (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title       VARCHAR(255) NOT NULL,
  description TEXT,
  created_at  TIMESTAMP DEFAULT NOW(),
  updated_at  TIMESTAMP DEFAULT NOW()
);
```

---

## 🌐 API Endpoints

### Health Check
```http
GET /
Response: { message: "API พร้อมใช้งาน...", timestamp: "..." }
```

### Demo Endpoint
```http
GET /api/demo
Response: {
  git: { title: "...", detail: "..." },
  docker: { title: "...", detail: "..." }
}
```

### Task CRUD

#### Get All Tasks
```http
GET /api/tasks
Response: { data: [ { id, title, description, createdAt, updatedAt }, ... ] }
```

#### Create Task
```http
POST /api/tasks
Body: { "title": "Task name", "description": "Optional description" }
Response: { data: { id, title, description, createdAt, updatedAt } }
```

#### Get Single Task
```http
GET /api/tasks/:id
Response: { data: { id, title, description, createdAt, updatedAt } }
```

#### Update Task
```http
PATCH /api/tasks/:id
Body: { "title": "New title", "description": "New description" }
Response: { data: { id, title, description, createdAt, updatedAt } }
```

#### Delete Task
```http
DELETE /api/tasks/:id
Response: { message: "ลบงานสำเร็จ" }
```

---

## 🚀 วิธีการรันโปรเจกต์

### 1. **ด้วย Docker Compose (แนะนำ)**

```bash
# Build และ start ทั้งระบบ
docker-compose up --build

# หรือ run ใน background
docker-compose up -d --build

# ดู logs
docker-compose logs -f

# Stop ทั้งระบบ
docker-compose down
```

**เข้าใช้งาน**:
- Frontend: http://localhost:8080
- Backend API: http://localhost:3000

### 2. **Development Mode (แยก container)**

**Backend**:
```bash
cd backend
npm install
npm run dev          # Run with nodemon + ts-node
```

**Frontend**:
```bash
cd frontend
npm install
npm run dev          # Run Quasar dev server
```

---

## 🔑 Environment Variables

### Backend (.env)
```env
DATABASE_URL="postgresql://user:password@host:5432/database"
PORT=3000
NODE_ENV=development
```

### Frontend (.env)
```env
API_URL=http://localhost:3000
```

---

## 📦 Dependencies

### Backend
- **express**: Web framework
- **cors**: Cross-Origin Resource Sharing
- **helmet**: Security middleware
- **morgan**: HTTP request logger
- **dotenv**: Environment variables
- **@prisma/client**: Database ORM
- **@prisma/adapter-pg**: PostgreSQL adapter
- **pg**: PostgreSQL driver
- **typescript**: TypeScript compiler
- **ts-node**: TypeScript execution
- **nodemon**: Auto-restart on file changes

### Frontend
- **quasar**: UI framework
- **vue**: Progressive JavaScript framework
- **vue-router**: Official router for Vue.js
- **axios**: HTTP client
- **@quasar/app-webpack**: Quasar CLI

---

## 🛡️ Security Features

1. **Helmet.js**: ตั้งค่า HTTP headers เพื่อความปลอดภัย
2. **CORS**: จำกัด cross-origin requests
3. **Non-root user**: Container run ด้วย user `node` (ไม่ใช่ root)
4. **Environment variables**: ไม่ hardcode sensitive data
5. **Healthcheck**: ตรวจสอบสถานะ service อัตโนมัติ

---

## 📊 Logging

### Access Logs
- บันทึกทุก request ที่เข้า `/api/demo`
- เก็บใน `backend/logs/access.log`
- Mount เป็น volume ใน Docker

### Application Logs
- Morgan middleware log ทุก HTTP request
- Prisma log queries, errors, warnings
- Console output ใน Docker logs

---

## 🧪 Testing

### ทดสอบ Backend API ด้วย curl

```bash
# Health check
curl http://localhost:3000/

# Get all tasks
curl http://localhost:3000/api/tasks

# Create task
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"This is a test"}'

# Get single task
curl http://localhost:3000/api/tasks/{task-id}

# Update task
curl -X PATCH http://localhost:3000/api/tasks/{task-id} \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated Title"}'

# Delete task
curl -X DELETE http://localhost:3000/api/tasks/{task-id}
```

---

## 🎓 สิ่งที่เรียนรู้จากโปรเจกต์นี้

### 1. **Docker & Containerization**
- Multi-stage builds เพื่อลดขนาด image
- Docker Compose orchestration
- Volume mounting สำหรับ persistent data
- Healthchecks และ service dependencies
- Network isolation

### 2. **Backend Development**
- RESTful API design
- TypeScript + Express.js
- Prisma ORM สำหรับ database operations
- Error handling และ validation
- Logging และ monitoring

### 3. **Frontend Development**
- Quasar Framework (Vue.js 3)
- Composition API (`<script setup>`)
- Axios สำหรับ HTTP requests
- State management ด้วย `ref()`
- Component-based architecture

### 4. **Database**
- PostgreSQL schema design
- Prisma migrations
- Cloud database (Supabase)
- Connection pooling

### 5. **DevOps**
- Environment configuration
- Build automation
- Container orchestration
- Production deployment strategies

---

## 🔍 จุดเด่นของโปรเจกต์

✅ **Full-Stack TypeScript**: ใช้ TypeScript ทั้ง backend และ frontend  
✅ **Modern Stack**: Express, Prisma, Vue 3, Quasar  
✅ **Containerized**: Docker + Docker Compose  
✅ **Cloud Database**: Supabase PostgreSQL  
✅ **Production-Ready**: Multi-stage builds, healthchecks, logging  
✅ **Best Practices**: Security headers, CORS, error handling  

---

## 📚 สรุป

โปรเจกต์นี้เป็นตัวอย่างที่ดีของ **Modern Full-Stack Web Application** ที่ใช้:
- **Backend**: Express.js + TypeScript + Prisma + PostgreSQL
- **Frontend**: Quasar (Vue.js 3)
- **Infrastructure**: Docker + Docker Compose
- **Database**: Supabase (Cloud PostgreSQL)

ระบบทำงานโดยการที่ Frontend (Quasar) ส่ง HTTP requests ไปยัง Backend (Express) ผ่าน REST API, Backend ใช้ Prisma ORM เพื่อติดต่อกับ PostgreSQL database บน Supabase, และทั้งระบบถูก containerize ด้วย Docker เพื่อให้ deploy ได้ง่ายและสม่ำเสมอในทุก environment

---

## 🔗 ไฟล์สำคัญที่ควรศึกษา

1. [backend/src/server.ts](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/src/server.ts) - Backend entry point
2. [backend/src/routes/task.routes.ts](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/src/routes/task.routes.ts) - API routes
3. [backend/src/prisma.ts](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/src/prisma.ts) - Database client
4. [backend/prisma/schema.prisma](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/prisma/schema.prisma) - Database schema
5. [frontend/src/pages/IndexPage.vue](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/frontend/src/pages/IndexPage.vue) - Main page
6. [docker-compose.yml](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/docker-compose.yml) - Orchestration config
7. [backend/Dockerfile](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/backend/Dockerfile) - Backend image
8. [frontend/Dockerfile](file:///c:/Users/autod/Desktop/work/P3-68/T2/som/ch3.1-proxy-server-main/frontend/Dockerfile) - Frontend image
