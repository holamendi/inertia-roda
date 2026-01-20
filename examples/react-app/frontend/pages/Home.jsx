import { Link } from "@inertiajs/react"

export default function Home({ message, app_name }) {
  return (
    <div style={{ fontFamily: "system-ui", padding: "2rem" }}>
      <h1>{app_name}</h1>
      <p>{message}</p>
      <nav>
        <Link href="/users">View Users →</Link>
      </nav>
    </div>
  )
}
