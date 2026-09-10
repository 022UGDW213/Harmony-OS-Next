import { StrictMode, useEffect, useState } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'

type Health = { status: string; version: string; database: string; kernel: string }

function App() {
  const [health, setHealth] = useState<Health | null>(null)
  const [message, setMessage] = useState('')
  const [reply, setReply] = useState('')

  const refresh = async () => {
    const response = await fetch(`${import.meta.env.VITE_API_URL ?? 'http://localhost:3003'}/health`)
    setHealth(await response.json())
  }
  useEffect(() => { refresh().catch(() => setHealth({ status: 'offline', version: '—', database: 'unavailable', kernel: 'unavailable' })) }, [])

  const send = async () => {
    if (!message.trim()) return
    const response = await fetch(`${import.meta.env.VITE_API_URL ?? 'http://localhost:3003'}/api/chat`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ message }) })
    const body = await response.json()
    setReply(body.reply ?? body.error ?? 'No response')
  }

  return <main>
    <nav><strong>HARMONY<span>OS</span></strong><small>FULL-STACK ARK PLATFORM</small><button onClick={() => refresh()}>Refresh status</button></nav>
    <section className="hero"><div><p className="eyebrow">ARKTS / ARKUI · REACT · FASTIFY · POSTGRES</p><h1>One control plane.<br /><em>Every system layer.</em></h1><p className="lede">A clean foundation for HarmonyOS NEXT development: native ArkUI clients, a typed web console, an API boundary, and a persistent data layer.</p></div><div className="orb"><i>⌬</i></div></section>
    <section className="grid"><article><p className="eyebrow">RUNTIME</p><h2>System health</h2><div className="status"><b className={health?.status === 'online' ? 'good' : ''}>{health?.status ?? 'checking'}</b><span>API service</span></div><div className="status"><b>{health?.database ?? 'checking'}</b><span>PostgreSQL</span></div><div className="status"><b>{health?.kernel ?? 'checking'}</b><span>Native boundary</span></div><small>Version {health?.version ?? '—'}</small></article><article><p className="eyebrow">REASONING</p><h2>API playground</h2><textarea value={message} onChange={event => setMessage(event.target.value)} placeholder="Send a message to the platform…" /><button className="primary" onClick={send}>Run request</button>{reply && <pre>{reply}</pre>}</article><article><p className="eyebrow">CLIENTS</p><h2>Build surfaces</h2><ul><li><strong>ArkTS / ArkUI</strong><span>Native device client</span></li><li><strong>React + TypeScript</strong><span>Browser control plane</span></li><li><strong>Fastify + PostgreSQL</strong><span>Service and data layer</span></li><li><strong>Native C/C++</strong><span>Privileged boundary</span></li></ul></article></section>
    <footer>HARMONY OS NEXT <span>·</span> clean architecture for distributed systems</footer>
  </main>
}

createRoot(document.getElementById('root')!).render(<StrictMode><App /></StrictMode>)
