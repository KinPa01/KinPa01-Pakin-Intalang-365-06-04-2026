import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding database...');

    // Clear existing tasks
    await prisma.task.deleteMany();

    // Create sample tasks
    const tasks = await prisma.task.createMany({
        data: [
            {
                title: 'Set up project structure',
                description: 'Initialize the backend and frontend folders with required dependencies.',
            },
            {
                title: 'Design database schema',
                description: 'Create Prisma schema with all required models and relations.',
            },
            {
                title: 'Implement REST API',
                description: 'Build CRUD endpoints for tasks using Express.',
            },
            {
                title: 'Write unit tests',
                description: 'Add Jest test cases for all API routes.',
            },
            {
                title: 'Deploy to production',
                description: 'Dockerize the app and deploy to the cloud.',
            },
            {
                title: '6604101365',
                description: 'ภาคิน อินแถลง',
            },
        ],
    });

    console.log(`✅ Seeded ${tasks.count} tasks.`);
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
