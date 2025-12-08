import React, { useState, useEffect } from 'react';
import TaskForm from './components/TaskForm';
import TaskList from './components/TaskList';
import { getTasks, createTask, updateTask, deleteTask } from './api/taskApi';

function App() {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [editingTask, setEditingTask] = useState(null);

  // Fetch all tasks
  const fetchTasks = async () => {
    try {
      setLoading(true);
      const response = await getTasks();
      setTasks(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch tasks. Make sure the backend is running.');
      console.error('Error fetching tasks:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  // Create or Update task
  const handleSubmit = async (taskData) => {
    try {
      if (editingTask) {
        await updateTask(editingTask._id, taskData);
        setEditingTask(null);
      } else {
        await createTask(taskData);
      }
      fetchTasks();
      setError(null);
    } catch (err) {
      setError('Failed to save task. Please try again.');
      console.error('Error saving task:', err);
    }
  };

  // Delete task
  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this task?')) {
      try {
        await deleteTask(id);
        fetchTasks();
        setError(null);
      } catch (err) {
        setError('Failed to delete task. Please try again.');
        console.error('Error deleting task:', err);
      }
    }
  };

  // Toggle task completion
  const handleToggleComplete = async (task) => {
    try {
      await updateTask(task._id, { ...task, completed: !task.completed });
      fetchTasks();
      setError(null);
    } catch (err) {
      setError('Failed to update task. Please try again.');
      console.error('Error updating task:', err);
    }
  };

  // Edit task
  const handleEdit = (task) => {
    setEditingTask(task);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Cancel editing
  const handleCancelEdit = () => {
    setEditingTask(null);
  };

  return (
    <div className="app">
      <h1>📝 Task Manager</h1>
      
      {error && <div className="error">{error}</div>}
      
      <TaskForm
        onSubmit={handleSubmit}
        editingTask={editingTask}
        onCancel={handleCancelEdit}
      />
      
      <TaskList
        tasks={tasks}
        loading={loading}
        onEdit={handleEdit}
        onDelete={handleDelete}
        onToggleComplete={handleToggleComplete}
      />
    </div>
  );
}

export default App;
