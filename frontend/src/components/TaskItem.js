import React from 'react';

const TaskItem = ({ task, onEdit, onDelete, onToggleComplete }) => {
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <div className="task-item">
      <div className="task-content">
        <div className={`task-title ${task.completed ? 'completed' : ''}`}>
          {task.title}
          <span className={`task-status ${task.completed ? 'completed' : 'pending'}`}>
            {task.completed ? 'Completed' : 'Pending'}
          </span>
        </div>
        {task.description && (
          <div className="task-description">{task.description}</div>
        )}
        <div className="task-date">Created: {formatDate(task.createdAt)}</div>
      </div>
      <div className="task-actions">
        <button
          className={`btn ${task.completed ? 'btn-secondary' : 'btn-success'}`}
          onClick={() => onToggleComplete(task)}
        >
          {task.completed ? 'Undo' : 'Complete'}
        </button>
        <button className="btn btn-primary" onClick={() => onEdit(task)}>
          Edit
        </button>
        <button className="btn btn-danger" onClick={() => onDelete(task._id)}>
          Delete
        </button>
      </div>
    </div>
  );
};

export default TaskItem;
