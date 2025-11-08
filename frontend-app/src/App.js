import { useState, useEffect } from 'react';
import { Layout, Card, Form, Input, Button, List, Checkbox, Space, Typography, message, Spin, Popconfirm } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, CheckOutlined, CloseOutlined } from '@ant-design/icons';

const { Header, Content } = Layout;
const { Title, Text } = Typography;
const { TextArea } = Input;

const API_URL =
  // import.meta.env.VITE_API_URL ||
  'http://localhost:8000';

function App() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form] = Form.useForm();
  const [editForm] = Form.useForm();

  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/api/todos`);
      const data = await response.json();
      setTodos(data);
    } catch (error) {
      message.error('Failed to fetch todos');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (values) => {
    try {
      const response = await fetch(`${API_URL}/api/todos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(values),
      });
      const newTodo = await response.json();
      setTodos([...todos, newTodo]);
      form.resetFields();
      message.success('Todo created!');
    } catch (error) {
      message.error('Failed to create todo');
      console.error(error);
    }
  };

  const handleUpdate = async (id) => {
    try {
      const values = await editForm.validateFields();
      const response = await fetch(`${API_URL}/api/todos/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(values),
      });
      const updated = await response.json();
      setTodos(todos.map(todo => todo.id === id ? updated : todo));
      setEditingId(null);
      message.success('Todo updated!');
    } catch (error) {
      message.error('Failed to update todo');
      console.error(error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await fetch(`${API_URL}/api/todos/${id}`, { method: 'DELETE' });
      setTodos(todos.filter(todo => todo.id !== id));
      message.success('Todo deleted!');
    } catch (error) {
      message.error('Failed to delete todo');
      console.error(error);
    }
  };

  const handleToggle = async (id) => {
    try {
      const response = await fetch(`${API_URL}/api/todos/${id}/complete`, { method: 'PATCH' });
      const updated = await response.json();
      setTodos(todos.map(todo => todo.id === id ? updated : todo));
    } catch (error) {
      message.error('Failed to update todo');
      console.error(error);
    }
  };

  const startEdit = (todo) => {
    setEditingId(todo.id);
    editForm.setFieldsValue({
      title: todo.title,
      description: todo.description || '',
    });
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header style={{ background: '#1890ff' }}>
        <Title level={2} style={{ color: 'white', margin: '16px 0' }}>
          📝 Todo App
        </Title>
      </Header>
      
      <Content style={{ padding: '24px 50px', maxWidth: 1200, margin: '0 auto', width: '100%' }}>
        <Space direction="vertical" size="large" style={{ width: '100%' }}>
          <Card title="Add New Todo" bordered={false}>
            <Form form={form} onFinish={handleCreate} layout="vertical">
              <Form.Item
                name="title"
                label="Title"
                rules={[{ required: true, message: 'Please enter a title' }]}
              >
                <Input placeholder="Enter todo title" size="large" />
              </Form.Item>
              <Form.Item name="description" label="Description">
                <TextArea rows={3} placeholder="Enter description (optional)" />
              </Form.Item>
              <Form.Item>
                <Button type="primary" htmlType="submit" icon={<PlusOutlined />} size="large">
                  Add Todo
                </Button>
              </Form.Item>
            </Form>
          </Card>

          <Card 
            title={`Todo List (${todos.length} total, ${todos.filter(t => t.completed).length} completed)`}
            bordered={false}
          >
            <Spin spinning={loading}>
              {todos.length === 0 ? (
                <Text type="secondary">No todos yet. Create your first one above!</Text>
              ) : (
                <List
                  dataSource={todos}
                  renderItem={(todo) => (
                    <List.Item
                      key={todo.id}
                      style={{
                        opacity: todo.completed ? 0.6 : 1,
                        background: editingId === todo.id ? '#f0f0f0' : 'white',
                        padding: '16px',
                        marginBottom: '8px',
                        borderRadius: '8px',
                      }}
                    >
                      {editingId === todo.id ? (
                        <div style={{ width: '100%' }}>
                          <Form form={editForm} layout="vertical">
                            <Form.Item
                              name="title"
                              rules={[{ required: true, message: 'Please enter a title' }]}
                            >
                              <Input placeholder="Title" />
                            </Form.Item>
                            <Form.Item name="description">
                              <TextArea rows={2} placeholder="Description" />
                            </Form.Item>
                            <Space>
                              <Button
                                type="primary"
                                icon={<CheckOutlined />}
                                onClick={() => handleUpdate(todo.id)}
                              >
                                Save
                              </Button>
                              <Button
                                icon={<CloseOutlined />}
                                onClick={() => setEditingId(null)}
                              >
                                Cancel
                              </Button>
                            </Space>
                          </Form>
                        </div>
                      ) : (
                        <div style={{ display: 'flex', width: '100%', alignItems: 'flex-start' }}>
                          <Checkbox
                            checked={todo.completed}
                            onChange={() => handleToggle(todo.id)}
                            style={{ marginRight: '16px', marginTop: '4px' }}
                          />
                          <div style={{ flex: 1 }}>
                            <Title
                              level={4}
                              style={{
                                margin: 0,
                                textDecoration: todo.completed ? 'line-through' : 'none',
                              }}
                            >
                              {todo.title}
                            </Title>
                            {todo.description && (
                              <Text type="secondary">{todo.description}</Text>
                            )}
                            <br />
                            <Text type="secondary" style={{ fontSize: '12px' }}>
                              Created: {new Date(todo.created_at).toLocaleString()}
                            </Text>
                          </div>
                          <Space>
                            <Button
                              icon={<EditOutlined />}
                              onClick={() => startEdit(todo)}
                            >
                              Edit
                            </Button>
                            <Popconfirm
                              title="Delete this todo?"
                              onConfirm={() => handleDelete(todo.id)}
                              okText="Yes"
                              cancelText="No"
                            >
                              <Button danger icon={<DeleteOutlined />}>
                                Delete
                              </Button>
                            </Popconfirm>
                          </Space>
                        </div>
                      )}
                    </List.Item>
                  )}
                />
              )}
            </Spin>
          </Card>

          <Card bordered={false} style={{ textAlign: 'center' }}>
            <Text type="secondary">
              API: <Text code>{API_URL}</Text>
            </Text>
          </Card>
        </Space>
      </Content>
    </Layout>
  );
}

export default App;