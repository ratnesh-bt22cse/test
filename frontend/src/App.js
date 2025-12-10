import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || '';

function App() {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState({ title: '', description: '' });
  const [editingId, setEditingId] = useState(null);

  const fetchTasks = async () => {
    try {
      setLoading(true);
      const res = await axios.get(`${API_URL}/api/tasks`);
      setTasks(res.data.data || []);
      setError(null);
    } catch (err) {
      setError('Failed to fetch tasks');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchTasks(); }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingId) {
        await axios.put(`${API_URL}/api/tasks/${editingId}`, formData);
        setEditingId(null);
      } else {
        await axios.post(`${API_URL}/api/tasks`, formData);
      }
      setFormData({ title: '', description: '' });
      fetchTasks();
    } catch (err) {
      setError('Failed to save task');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Delete this task?')) {
      try {
        await axios.delete(`${API_URL}/api/tasks/${id}`);
        fetchTasks();
      } catch (err) {
        setError('Failed to delete task');
      }
    }
  };

  const handleToggle = async (task) => {
    try {
      await axios.put(`${API_URL}/api/tasks/${task._id}`, { ...task, completed: !task.completed });
      fetchTasks();
    } catch (err) {
      setError('Failed to update task');
    }
  };

  const handleEdit = (task) => {
    setFormData({ title: task.title, description: task.description });
    setEditingId(task._id);
  };

  return (
    <div className="app">
      <h1>Task Manager (Microservices)</h1>
      
      {error && <div className="error">{error}</div>}
      
      <div className="card">
        <h2>{editingId ? 'Edit Task' : 'Add Task'}</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Title</label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({...formData, title: e.target.value})}
              required
            />
          </div>
          <div className="form-group">
            <label>Description</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({...formData, description: e.target.value})}
            />
          </div>
          <button type="submit" className="btn btn-primary">
            {editingId ? 'Update' : 'Add'} Task
          </button>
          {editingId && (
            <button type="button" className="btn" onClick={() => {
              setEditingId(null);
              setFormData({ title: '', description: '' });
            }}>Cancel</button>
          )}
        </form>
      </div>

      <div className="card">
        <h2>Tasks ({tasks.length})</h2>
        {loading ? (
          <div className="loading">Loading...</div>
        ) : tasks.length === 0 ? (
          <p>No tasks yet</p>
        ) : (
          tasks.map(task => (
            <div key={task._id} className="task-item">
              <div>
                <span className={`task-title ${task.completed ? 'completed' : ''}`}>
                  {task.title}
                </span>
                <span className={`status-badge ${task.completed ? 'completed' : 'pending'}`}>
                  {task.completed ? 'Done' : 'Pending'}
                </span>
                {task.description && <p style={{color: '#666', fontSize: '14px'}}>{task.description}</p>}
              </div>
              <div>
                <button className="btn btn-success" onClick={() => handleToggle(task)}>
                  {task.completed ? 'Undo' : 'Done'}
                </button>
                <button className="btn btn-primary" onClick={() => handleEdit(task)}>Edit</button>
                <button className="btn btn-danger" onClick={() => handleDelete(task._id)}>Delete</button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default App;
