import { defineBoot } from '#q-app/wrappers'
import axios from 'axios'

// สร้างเพียงครั้งเดียว และใช้ baseURL เป็น /api เท่านั้น
const api = axios.create({ baseURL: '/api' })

export default defineBoot(({ app }) => {
  app.config.globalProperties.$axios = axios
  app.config.globalProperties.$api = api
})

export { api }