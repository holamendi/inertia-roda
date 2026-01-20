import { Link } from "@inertiajs/react"

export default function UsersIndex({ users, app_name }) {
  return (
    <div style={{ fontFamily: "system-ui", padding: "2rem" }}>
      <h1>Users</h1>
      <p>Part of {app_name}</p>

      <table style={{ borderCollapse: "collapse", width: "100%", marginTop: "1rem" }}>
        <thead>
          <tr>
            <th style={{ border: "1px solid #ddd", padding: "8px", textAlign: "left" }}>ID</th>
            <th style={{ border: "1px solid #ddd", padding: "8px", textAlign: "left" }}>Name</th>
            <th style={{ border: "1px solid #ddd", padding: "8px", textAlign: "left" }}>Email</th>
            <th style={{ border: "1px solid #ddd", padding: "8px", textAlign: "left" }}>Actions</th>
          </tr>
        </thead>
        <tbody>
          {users.map((user) => (
            <tr key={user.id}>
              <td style={{ border: "1px solid #ddd", padding: "8px" }}>{user.id}</td>
              <td style={{ border: "1px solid #ddd", padding: "8px" }}>{user.name}</td>
              <td style={{ border: "1px solid #ddd", padding: "8px" }}>{user.email}</td>
              <td style={{ border: "1px solid #ddd", padding: "8px" }}>
                <Link href={`/users/${user.id}`}>View</Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <nav style={{ marginTop: "1rem" }}>
        <Link href="/">← Back to Home</Link>
      </nav>
    </div>
  )
}
