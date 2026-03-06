import { defineBoot } from '#q-app/wrappers'
import axios from 'axios'

// เปลี่ยนจาก /api เป็น URL ของ Render ที่คุณเพิ่งได้มา
const api = axios.create({
  baseURL: 'https://kinpa01-pakin-intalang-365-06-04-2026-2.onrender.com/api'
})

export default defineBoot(({ app }) => {
  app.config.globalProperties.$axios = axios
  app.config.globalProperties.$api = api
})

export { api }