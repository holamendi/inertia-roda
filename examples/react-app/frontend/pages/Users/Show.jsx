import { Link } from "@inertiajs/react"

export default function UsersShow({ user, app_name }) {
  return (
    <div style={{ fontFamily: "system-ui", padding: "2rem" }}>
      <h1>User Details</h1>
      <p>Part of {app_name}</p>

      <dl style={{ marginTop: "1rem" }}>
        <dt style={{ fontWeight: "bold" }}>ID</dt>
        <dd>{user.id}</dd>

        <dt style={{ fontWeight: "bold", marginTop: "1rem" }}>Name</dt>
        <dd>{user.name}</dd>

        <dt style={{ fontWeight: "bold", marginTop: "1rem" }}>Email</dt>
        <dd>{user.email}</dd>
      </dl>

      <nav style={{ marginTop: "2rem" }}>
        <Link href="/users">← Back to Users</Link>
      </nav>
    </div>
  )
}
