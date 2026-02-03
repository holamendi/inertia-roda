<script>
  import { router } from "@inertiajs/svelte";

  export let todos = [];

  let title = "";

  function addTodo(e) {
    e.preventDefault();
    if (!title.trim()) return;
    router.post("/todos", { title: title.trim() });
    title = "";
  }

  function toggleTodo(id) {
    router.put(`/todos/${id}`);
  }

  function deleteTodo(id) {
    router.delete(`/todos/${id}`);
  }
</script>

<div class="container">
  <h1>Todos</h1>

  <form on:submit={addTodo}>
    <input
      type="text"
      bind:value={title}
      placeholder="What needs to be done?"
    />
    <button type="submit">Add</button>
  </form>

  {#if todos.length === 0}
    <p class="empty">No todos yet. Add one above!</p>
  {:else}
    <ul>
      {#each todos as todo (todo.id)}
        <li class:completed={todo.completed}>
          <label>
            <input
              type="checkbox"
              checked={todo.completed}
              on:change={() => toggleTodo(todo.id)}
            />
            <span>{todo.title}</span>
          </label>
          <button class="delete" on:click={() => deleteTodo(todo.id)}>
            &times;
          </button>
        </li>
      {/each}
    </ul>
  {/if}
</div>

<style>
  .container {
    max-width: 500px;
    margin: 2rem auto;
    font-family: system-ui, -apple-system, sans-serif;
  }

  h1 {
    font-size: 1.5rem;
    margin-bottom: 1rem;
  }

  form {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
  }

  input[type="text"] {
    flex: 1;
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 1rem;
  }

  button[type="submit"] {
    padding: 0.5rem 1rem;
    background: #333;
    color: #fff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
  }

  ul {
    list-style: none;
    padding: 0;
  }

  li {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
  }

  label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    cursor: pointer;
  }

  .completed span {
    text-decoration: line-through;
    color: #999;
  }

  .delete {
    background: none;
    border: none;
    font-size: 1.25rem;
    color: #999;
    cursor: pointer;
    padding: 0 0.25rem;
  }

  .delete:hover {
    color: #e33;
  }

  .empty {
    color: #999;
    font-style: italic;
  }
</style>
