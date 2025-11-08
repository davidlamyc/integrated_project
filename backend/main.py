"""
FastAPI Backend for Todo Application
Deployed to Azure App Service
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import os
import logging

from database import get_db, engine, init_db
from models import Todo
from schemas import TodoCreate, TodoUpdate, TodoResponse

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Todo API",
    description="Simple Todo API with SQL Server backend",
    version="1.0.0"
)

# CORS configuration
origins = [
    "*"
    # "http://localhost:5173",  # Local development
    # "http://localhost:3000",  # Alternative local dev
    # os.getenv("FRONTEND_URL", "*"),  # Production frontend URL
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize database on startup
@app.on_event("startup")
async def startup_event():
    logger.info("Starting up application...")
    # init_db()
    logger.info("Database initialized successfully")

# Health check endpoints
@app.get("/")
async def root():
    return {
        "status": "healthy",
        "message": "Todo API is running",
        "version": "1.0.0"
    }

@app.get("/api/health")
async def health_check():
    """Detailed health check including database connectivity"""
    try:
        # Test database connection
        db = next(get_db())
        db.execute("SELECT 1")
        db_status = "connected"
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        db_status = f"error: {str(e)}"
    
    return {
        "status": "healthy" if db_status == "connected" else "unhealthy",
        "database": db_status,
        "environment": os.getenv("ENVIRONMENT", "unknown"),
        "sql_server": os.getenv("SQL_SERVER_FQDN", "not configured")
    }

# Todo CRUD endpoints
@app.get("/api/todos", response_model=List[TodoResponse])
def get_todos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all todos with pagination"""
    try:
        # todos = db.query(Todo).offset(skip).limit(limit).all()
        todos = [
            {"id": 1, "title": "Learn FastAPI", "completed": False, "description": "Learn FastAPI", "created_at": "2025-11-08T01:53:00.000Z", "updated_at": "2025-11-08T01:53:00.000Z"},
            {"id": 2, "title": "Build a simple API", "completed": True, "description": "Build a simple API", "created_at": "2025-11-08T01:53:00.000Z", "updated_at": "2025-11-08T01:53:00.000Z"},
            {"id": 3, "title": "Deploy the API", "completed": False, "description": "Deploy the API", "created_at": "2025-11-08T01:53:00.000Z", "updated_at": "2025-11-08T01:53:00.000Z"},
        ]
        return todos
    except Exception as e:
        logger.error(f"Error fetching todos: {e}")
        raise HTTPException(status_code=500, detail=f"Error fetching todos: {str(e)}")

@app.get("/api/todos/{todo_id}", response_model=TodoResponse)
def get_todo(todo_id: int, db: Session = Depends(get_db)):
    """Get a specific todo by ID"""
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo

@app.post("/api/todos", response_model=TodoResponse, status_code=201)
def create_todo(todo: TodoCreate, db: Session = Depends(get_db)):
    """Create a new todo"""
    try:
        db_todo = Todo(
            title=todo.title,
            description=todo.description,
            completed=False
        )
        db.add(db_todo)
        db.commit()
        db.refresh(db_todo)
        logger.info(f"Created todo: {db_todo.id}")
        return db_todo
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating todo: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating todo: {str(e)}")

@app.put("/api/todos/{todo_id}", response_model=TodoResponse)
def update_todo(todo_id: int, todo: TodoUpdate, db: Session = Depends(get_db)):
    """Update an existing todo"""
    db_todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not db_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    try:
        if todo.title is not None:
            db_todo.title = todo.title
        if todo.description is not None:
            db_todo.description = todo.description
        if todo.completed is not None:
            db_todo.completed = todo.completed
        
        db.commit()
        db.refresh(db_todo)
        logger.info(f"Updated todo: {todo_id}")
        return db_todo
    except Exception as e:
        db.rollback()
        logger.error(f"Error updating todo: {e}")
        raise HTTPException(status_code=500, detail=f"Error updating todo: {str(e)}")

@app.delete("/api/todos/{todo_id}", status_code=204)
def delete_todo(todo_id: int, db: Session = Depends(get_db)):
    """Delete a todo"""
    db_todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not db_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    try:
        db.delete(db_todo)
        db.commit()
        logger.info(f"Deleted todo: {todo_id}")
        return None
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting todo: {e}")
        raise HTTPException(status_code=500, detail=f"Error deleting todo: {str(e)}")

@app.patch("/api/todos/{todo_id}/complete", response_model=TodoResponse)
def toggle_todo_completion(todo_id: int, db: Session = Depends(get_db)):
    """Toggle todo completion status"""
    db_todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not db_todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    try:
        db_todo.completed = not db_todo.completed
        db.commit()
        db.refresh(db_todo)
        logger.info(f"Toggled completion for todo: {todo_id} to {db_todo.completed}")
        return db_todo
    except Exception as e:
        db.rollback()
        logger.error(f"Error toggling todo completion: {e}")
        raise HTTPException(status_code=500, detail=f"Error toggling completion: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)