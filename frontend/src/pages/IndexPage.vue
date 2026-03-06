<template>
  <q-page padding>
    <div class="text-h4 q-mb-md">
      Task List (Express + Prisma + Supabase)
    </div>

    <div class="q-mb-md row items-center q-gutter-sm">
      <q-btn
        color="primary"
        label="Reload Tasks"
        :loading="loading"
        @click="fetchTasks"
      />
      <span v-if="errorMessage" class="text-negative">
        {{ errorMessage }}
      </span>
    </div>

    <q-spinner v-if="loading" color="primary" size="2em" />

    <div v-else>
      <div v-if="tasks.length === 0" class="text-grey">
        ยังไม่มีงานในระบบ ลองสร้างด้วย curl / Postman ก่อนนะ
      </div>

      <q-list v-else bordered separator>
        <q-item v-for="task in tasks" :key="task.id">
          <q-item-section>
            <q-item-label>{{ task.title }}</q-item-label>
            <q-item-label caption>{{ task.description }}</q-item-label>
          </q-item-section>
          <q-item-section side>
            <q-item-label caption>
              {{ new Date(task.createdAt).toLocaleString() }}
            </q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue';
// นำเข้า api ที่ตั้งค่า baseURL: '/api' ไว้แล้วจากไฟล์ boot/axios.js
import { api } from 'boot/axios'; 

const tasks = ref([]);
const loading = ref(false);
const errorMessage = ref('');

const fetchTasks = async () => {
  loading.value = true;
  errorMessage.value = '';

  try {
    // เรียกไปที่ /tasks (ซึ่งจะกลายเป็น /api/tasks อัตโนมัติผ่าน axios instance)
    const res = await api.get('/tasks');
    
    // ตรวจสอบโครงสร้างข้อมูลที่ Backend ส่งมา 
    // ถ้าส่งมาในรูปแบบ { data: [...] } ให้ใช้ res.data.data
    tasks.value = res.data.data || res.data; 
    
    console.log('Successfully loaded tasks:', tasks.value);
  } catch (err) {
    console.error('API Error:', err);
    errorMessage.value = 'โหลดงานจากฐานข้อมูลไม่สำเร็จ';
  } finally {
    loading.value = false;
  }
};

// เรียกดึงข้อมูลทันทีที่หน้าจอโหลดเสร็จ
onMounted(fetchTasks);
</script>