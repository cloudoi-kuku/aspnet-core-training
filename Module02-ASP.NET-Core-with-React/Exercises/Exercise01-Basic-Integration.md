# Exercise 1: Setting Up React with ASP.NET Core

## 🎯 Objective
Create a full-stack application with React frontend and ASP.NET Core backend, establishing the foundation for modern web development.

## ⏱️ Estimated Time
45 minutes

## 📋 Prerequisites
- Completed Module 1
- .NET 8.0 SDK installed
- Node.js 18+ installed
- Basic React knowledge
- Understanding of RESTful APIs

## 📝 Instructions

### Part 1: Create ASP.NET Core Web API (10 minutes)

1. **Create a new Web API project**:
   ```bash
   dotnet new webapi -n ReactTodoApp --framework net8.0
   cd ReactTodoApp
   ```

2. **Add necessary NuGet packages**:
   ```bash
   dotnet add package Microsoft.AspNetCore.SpaServices.Extensions --version 8.0.0
   ```

3. **Create a Todo model** in `Models/Todo.cs`:
   ```csharp
   namespace ReactTodoApp.Models
   {
       public class Todo
       {
           public int Id { get; set; }
           public string Title { get; set; } = string.Empty;
           public bool IsCompleted { get; set; }
           public DateTime CreatedAt { get; set; }
       }
   }
   ```

4. **Create TodoController** in `Controllers/TodoController.cs`:
   ```csharp
   using Microsoft.AspNetCore.Mvc;
   using ReactTodoApp.Models;

   namespace ReactTodoApp.Controllers
   {
       [ApiController]
       [Route("api/[controller]")]
       public class TodoController : ControllerBase
       {
           private static readonly List<Todo> _todos = new()
           {
               new Todo { Id = 1, Title = "Learn React", IsCompleted = false, CreatedAt = DateTime.Now },
               new Todo { Id = 2, Title = "Build API", IsCompleted = true, CreatedAt = DateTime.Now }
           };

           [HttpGet]
           public ActionResult<IEnumerable<Todo>> GetTodos()
           {
               return Ok(_todos);
           }

           [HttpGet("{id}")]
           public ActionResult<Todo> GetTodo(int id)
           {
               var todo = _todos.FirstOrDefault(t => t.Id == id);
               if (todo == null)
                   return NotFound();

               return Ok(todo);
           }

           [HttpPost]
           public ActionResult<Todo> CreateTodo(Todo todo)
           {
               todo.Id = _todos.Count > 0 ? _todos.Max(t => t.Id) + 1 : 1;
               todo.CreatedAt = DateTime.Now;
               _todos.Add(todo);

               return CreatedAtAction(nameof(GetTodo), new { id = todo.Id }, todo);
           }

           [HttpPut("{id}")]
           public ActionResult UpdateTodo(int id, Todo todo)
           {
               var existingTodo = _todos.FirstOrDefault(t => t.Id == id);
               if (existingTodo == null)
                   return NotFound();

               existingTodo.Title = todo.Title;
               existingTodo.IsCompleted = todo.IsCompleted;

               return NoContent();
           }

           [HttpDelete("{id}")]
           public ActionResult DeleteTodo(int id)
           {
               var todo = _todos.FirstOrDefault(t => t.Id == id);
               if (todo == null)
                   return NotFound();

               _todos.Remove(todo);
               return NoContent();
           }
       }
   }
   ```

### Part 2: Create React Application (15 minutes)

1. **Create React app in the project root**:
   ```bash
   npm create vite@latest clientapp -- --template react-ts
   ```

2. **Install additional dependencies**:
   ```bash
   cd clientapp
   npm install axios react-router-dom @types/react-router-dom
   ```

3. **Configure Vite for ASP.NET Core integration**. Update `clientapp/vite.config.ts`:
   ```typescript
  import { defineConfig } from 'vite'
  import react from '@vitejs/plugin-react'

  // https://vitejs.dev/config/
  export default defineConfig({
    plugins: [react()],
    server: {
      port: 3000,
      proxy: {
        '/api': {
          target: 'http://localhost:5000',
          changeOrigin: true,
          secure: false,
        },
        '/swagger': {
          target: 'http://localhost:5000',
          changeOrigin: true,
          secure: false,
        }
      }
    },
    build: {
      outDir: '../wwwroot',
      emptyOutDir: true
    }
  })
   ```

4. **Return to project root**:
   ```bash
   cd ..
   ```

5. **Configure ASP.NET Core to serve React app**. Update `Program.cs`:
   ```csharp
  var builder = WebApplication.CreateBuilder(args);

  // Add services to the container.
  builder.Services.AddControllers();
  builder.Services.AddEndpointsApiExplorer();
  builder.Services.AddSwaggerGen();

  // Configure CORS
  builder.Services.AddCors(options =>
  {
      options.AddPolicy("AllowReactApp",
          policy =>
          {
              policy.WithOrigins("http://localhost:3000")
                    .AllowAnyHeader()
                    .AllowAnyMethod();
          });
  });

  var app = builder.Build();

  // Configure the HTTP request pipeline.
  if (app.Environment.IsDevelopment())
  {
      app.UseSwagger();
      app.UseSwaggerUI();
  }

  app.UseHttpsRedirection();

  app.UseCors("AllowReactApp");

  app.UseAuthorization();

  app.MapControllers();

  // Serve static files from wwwroot
  app.UseStaticFiles();

  // Fallback to index.html for client-side routing
  app.MapFallbackToFile("index.html");

  app.Run();
   ```
6. Update Properties/launchsettings.json to use port 5000 for the backend:
```json
{
  "$schema": "http://json.schemastore.org/launchsettings.json",
  "iisSettings": {
    "windowsAuthentication": false,
    "anonymousAuthentication": true,
    "iisExpress": {
      "applicationUrl": "http://localhost:34497",
      "sslPort": 44341
    }
  },
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "https": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:7193;http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```


### Part 3: Create React Components (15 minutes)

1. **Create API service** in `clientapp/src/services/todoService.ts`:
   ```typescript
   import axios from 'axios';

   const API_BASE_URL = '/api/todo';

   export interface Todo {
     id?: number;
     title: string;
     isCompleted: boolean;
     createdAt?: string;
   }

   export const todoService = {
     getAll: async (): Promise<Todo[]> => {
       const response = await axios.get<Todo[]>(API_BASE_URL);
       return response.data;
     },

     getById: async (id: number): Promise<Todo> => {
       const response = await axios.get<Todo>(`${API_BASE_URL}/${id}`);
       return response.data;
     },

     create: async (todo: Todo): Promise<Todo> => {
       const response = await axios.post<Todo>(API_BASE_URL, todo);
       return response.data;
     },

     update: async (id: number, todo: Todo): Promise<void> => {
       await axios.put(`${API_BASE_URL}/${id}`, todo);
     },

     delete: async (id: number): Promise<void> => {
       await axios.delete(`${API_BASE_URL}/${id}`);
     }
   };
   ```

2. **Create TodoList component** in `clientapp/src/components/TodoList.tsx`:
   ```typescript
   import React, { useState, useEffect } from 'react';
   import { Todo, todoService } from '../services/todoService';

   const TodoList: React.FC = () => {
     const [todos, setTodos] = useState<Todo[]>([]);
     const [newTodo, setNewTodo] = useState('');
     const [loading, setLoading] = useState(true);
     const [error, setError] = useState<string | null>(null);

     useEffect(() => {
       loadTodos();
     }, []);

     const loadTodos = async () => {
       try {
         setLoading(true);
         const data = await todoService.getAll();
         setTodos(data);
         setError(null);
       } catch (err) {
         setError('Failed to load todos');
         console.error(err);
       } finally {
         setLoading(false);
       }
     };

     const handleAddTodo = async (e: React.FormEvent) => {
       e.preventDefault();
       if (!newTodo.trim()) return;

       try {
         const todo: Todo = {
           title: newTodo,
           isCompleted: false
         };
         const created = await todoService.create(todo);
         setTodos([...todos, created]);
         setNewTodo('');
       } catch (err) {
         setError('Failed to add todo');
       }
     };

     const handleToggle = async (todo: Todo) => {
       try {
         const updated = { ...todo, isCompleted: !todo.isCompleted };
         await todoService.update(todo.id!, updated);
         setTodos(todos.map(t => t.id === todo.id ? updated : t));
       } catch (err) {
         setError('Failed to update todo');
       }
     };

     const handleDelete = async (id: number) => {
       try {
         await todoService.delete(id);
         setTodos(todos.filter(t => t.id !== id));
       } catch (err) {
         setError('Failed to delete todo');
       }
     };

     if (loading) return <div>Loading...</div>;
     if (error) return <div className="error">{error}</div>;

     return (
       <div className="todo-container">
         <h1>Todo List</h1>

         <form onSubmit={handleAddTodo} className="add-todo-form">
           <input
             type="text"
             value={newTodo}
             onChange={(e) => setNewTodo(e.target.value)}
             placeholder="Add a new todo..."
             className="todo-input"
           />
           <button type="submit" className="add-button">Add</button>
         </form>

         <ul className="todo-list">
           {todos.map(todo => (
             <li key={todo.id} className={`todo-item ${todo.isCompleted ? 'completed' : ''}`}>
               <input
                 type="checkbox"
                 checked={todo.isCompleted}
                 onChange={() => handleToggle(todo)}
               />
               <span>{todo.title}</span>
               <button
                 onClick={() => handleDelete(todo.id!)}
                 className="delete-button"
               >
                 Delete
               </button>
             </li>
           ))}
         </ul>
       </div>
     );
   };

   export default TodoList;
   ```

3. **Update App.tsx** in `clientapp/src/App.tsx`:
   ```typescript
   import React from 'react';
   import './App.css';
   import TodoList from './components/TodoList';

   function App() {
     return (
       <div className="App">
         <header className="App-header">
           <h1>React + ASP.NET Core Todo App</h1>
         </header>
         <main>
           <TodoList />
         </main>
       </div>
     );
   }

   export default App;
   ```

4. **Add styles** to `clientapp/src/App.css`:
   ```css
   .App {
     text-align: center;
     min-height: 100vh;
     background-color: #f5f5f5;
   }

   .App-header {
     background-color: #282c34;
     padding: 20px;
     color: white;
   }

   .todo-container {
     max-width: 600px;
     margin: 40px auto;
     padding: 20px;
     background: white;
     border-radius: 8px;
     box-shadow: 0 2px 4px rgba(0,0,0,0.1);
   }

   .add-todo-form {
     display: flex;
     gap: 10px;
     margin-bottom: 20px;
   }

   .todo-input {
     flex: 1;
     padding: 10px;
     border: 1px solid #ddd;
     border-radius: 4px;
     font-size: 16px;
   }

   .add-button {
     padding: 10px 20px;
     background-color: #4CAF50;
     color: white;
     border: none;
     border-radius: 4px;
     cursor: pointer;
   }

   .add-button:hover {
     background-color: #45a049;
   }

   .todo-list {
     list-style: none;
     padding: 0;
   }

   .todo-item {
     display: flex;
     align-items: center;
     padding: 10px;
     border-bottom: 1px solid #eee;
     gap: 10px;
   }

   .todo-item.completed span {
     text-decoration: line-through;
     color: #888;
   }

   .delete-button {
     margin-left: auto;
     padding: 5px 10px;
     background-color: #f44336;
     color: white;
     border: none;
     border-radius: 4px;
     cursor: pointer;
   }

   .delete-button:hover {
     background-color: #da190b;
   }

   .error {
     color: red;
     padding: 10px;
     background-color: #ffebee;
     border-radius: 4px;
     margin: 10px 0;
   }
   ```

### Part 4: Test the Application (5 minutes)

1. **Important**: Check your ASP.NET Core port in `Properties/launchSettings.json` and update the Vite proxy target accordingly.

2. **Start the Vite development server** (in a separate terminal):
   ```bash
   cd clientapp
   npm run dev
   ```

3. **Run the ASP.NET Core application** (in another terminal):
   ```bash
   dotnet run
   ```

4. **Test the features**:
   - The app should open at https://localhost:[port]
   - Add new todos
   - Toggle completion status
   - Delete todos
   - Check that API calls work in the Network tab

5. **Test the API directly**:
   - Navigate to https://localhost:[port]/swagger
   - Test the API endpoints

## ✅ Success Criteria

- [ ] ASP.NET Core Web API is running with Todo endpoints
- [ ] React application loads and displays todos
- [ ] Can add new todos
- [ ] Can toggle todo completion
- [ ] Can delete todos
- [ ] No console errors
- [ ] API calls visible in browser DevTools

## 🚀 Bonus Challenges

1. **Add Edit Functionality**:
   - Allow inline editing of todo titles
   - Add an edit button and save changes

2. **Add Filtering**:
   - Filter todos by status (All, Active, Completed)
   - Add a search box to filter by title

3. **Persist Data**:
   - Replace in-memory storage with Entity Framework Core
   - Add a SQLite database

4. **Add Authentication**:
   - Implement user authentication
   - Associate todos with users

## 🤔 Reflection Questions

1. How does the proxy configuration work between React and ASP.NET Core?
2. What are the benefits of separating frontend and backend?
3. How would you handle errors more gracefully?
4. What security considerations should you implement?

## 🆘 Troubleshooting

**Issue**: CORS errors
**Solution**: The SPA middleware handles this in development. For production, configure CORS properly.

**Issue**: React app not loading
**Solution**: Check that Node.js is installed and `npm install` was run in the clientapp folder.

**Issue**: API calls failing (404 errors)
**Solution**:
1. Check the browser console and ensure the API is running on the correct port
2. Verify the Vite proxy configuration matches your ASP.NET Core port
3. Check `Properties/launchSettings.json` for the correct HTTPS port
4. Update `vite.config.ts` proxy target to match

**Issue**: Vite dev server not starting
**Solution**:
1. Ensure you're in the clientapp directory when running npm commands
2. Check that all dependencies are installed: `npm install`
3. Verify Node.js version is 18+ with `node --version`

**Issue**: Build files not found (dist folder)
**Solution**:
1. Run `npm run build` in the clientapp folder first
2. Ensure the ASP.NET Core configuration points to `clientapp/dist` not `clientapp/build`

**Issue**: Hot reload not working
**Solution**:
1. Make sure you're running `dotnet run` from the project root
2. The SPA middleware should automatically start the Vite dev server
3. Check that the npmScript is set to "dev" not "start"
4. Ensure you're running in Development mode

---

