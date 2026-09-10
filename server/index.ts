import Fastify from 'fastify'
import cors from '@fastify/cors'
import postgres from '@fastify/postgres'

const app = Fastify({ logger: true })
await app.register(cors, { origin: true })
if (process.env.DATABASE_URL) await app.register(postgres, { connectionString: process.env.DATABASE_URL })

app.get('/health', async () => ({ status: 'online', version: '1.0.0', database: process.env.DATABASE_URL ? 'configured' : 'development', kernel: 'isolated' }))
app.get('/api/capabilities', async () => ({ clients: ['arkts', 'react'], services: ['health', 'chat', 'capabilities'], nativeBoundary: true }))
app.post<{ Body: { message?: string } }>('/api/chat', async request => {
  const message = request.body?.message?.trim()
  if (!message) return { error: 'message is required' }
  return { reply: `Harmony control plane received: ${message}`, mode: 'development' }
})

const port = Number(process.env.PORT ?? 3003)
await app.listen({ port, host: '0.0.0.0' })
