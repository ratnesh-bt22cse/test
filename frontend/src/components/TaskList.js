import React from 'react';
import TaskItem from './TaskItem';

const TaskList = ({ tasks, loading, onEdit, onDelete, onToggleComplete }) => {
  if (loading) {
    return <div className="loading">Loading tasks...</div>;
  }

  return (
    <div className="task-list">
      <h2>Tasks ({tasks.length})</h2>
      {tasks.length === 0 ? (
        <div className="no-tasks">No tasks found. Add a new task to get started!</div>
      ) : (
        tasks.map((task) => (
          <TaskItem
            key={task._id}
            task={task}
            onEdit={onEdit}
            onDelete={onDelete}
            onToggleComplete={onToggleComplete}
          />
        ))
      )}
    </div>
  );
};

export default TaskList;
