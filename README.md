# 🏪 Customer Service

A Rails API microservice that manages customer data and listens to order events to update customer order counts.

## 🏗️ Architecture

This service is part of a microservices architecture that includes:
- **Customer Service** (this service) - Manages customer data and order counts
- **Order Service** - Handles order creation and publishes events
- **RabbitMQ** - Message broker for event-driven communication

### Event Flow
```
Order Service → RabbitMQ → Customer Service
     ↓              ↓              ↓
Creates Order → Publishes Event → Updates Order Count
```

## 🚀 Quick Start

### Prerequisites
- Ruby 3.2.8
- Rails 8.0.2
- PostgreSQL
- Docker (for RabbitMQ)

### 1. Setup RabbitMQ
```bash
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:4-management
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Database Setup
```bash
# Create and migrate database
rails db:create
rails db:migrate

# Seed with sample data
rails db:seed
```

### 4. Start the Server
```bash
rails server -p 3001
```

## 🔧 Environment Variables

Create a `.env` file in the root directory:

```bash
# Database
DATABASE_URL=postgresql://localhost/customer_service_development
```

## 📡 API Endpoints

### GET /api/v1/customers/:id

Retrieves customer information including order count.

**Request:**
```bash
curl http://localhost:3001/api/v1/customers/1
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "customer_name": "John Doe",
    "address": "123 Main St, City, State 12345",
    "orders_count": 5,
    "created_at": "2025-07-14T10:00:00.000Z",
    "updated_at": "2025-07-14T10:00:00.000Z"
  }
}
```

## 🎯 Event Processing

### Order Created Events

The service listens to `order_created` events from RabbitMQ and automatically updates customer order counts.

**Event Format:**
```json
{
  "event_type": "order_created",
  "data": {
    "customer_id": 1,
    "order_id": 123,
    "product_name": "Book",
    "quantity": 2,
    "price": 29.99
  }
}
```

**Processing Flow:**
1. Receives event from RabbitMQ queue `orders.events`
2. Parses the JSON payload
3. Extracts `customer_id` from event data
4. Calls `UpdateOrderCountService` to increment order count
5. Acknowledges the message

## 🏛️ Design Patterns

### Service Object Pattern
- `UpdateOrderCountService` - Handles order count incrementing logic
- `OrderCreatedSubscriber` - Handles RabbitMQ Subscriber logic

### Singleton Pattern
- `RabbitMQConnection` - Manages single RabbitMQ connection instance

### Adapter Pattern
- `CustomerApiAdapter` (in Order Service) - Handles HTTP communication
- Provides consistent interface for external service calls

## 🧪 Testing

### Run All Tests
```bash
bundle exec rspec
```

## 📊 Database Schema

### Customers Table
```sql
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  customer_name VARCHAR NOT NULL,
  address VARCHAR NOT NULL,
  orders_count INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

## 🔍 Monitoring

### RabbitMQ Management Interface
- **URL**: http://localhost:15672
- **Username**: guest
- **Password**: guest

## 📦 Dependencies

### Key Gems
- `rails` - Web framework
- `pg` - PostgreSQL adapter
- `bunny` - RabbitMQ client
- `faraday` - HTTP client (for external calls)
- `rspec-rails` - Testing framework
- `factory_bot_rails` - Test data factories
- `faker` - Fake data generation

## 🤝 Integration with Order Service

This service integrates with the Order Service through:

1. **HTTP API**: Order Service calls Customer API to verify customers
2. **Event Processing**: Listens to order creation events
3. **Data Consistency**: Maintains accurate order counts

## 🧪 Testing the Full Flow

### 1. Start All Services
```bash
# Terminal 1: RabbitMQ
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:4-management

# Terminal 2: Customer Service
cd customer_service
rails server -p 3001

# Terminal 4: Order Service
cd order_service
rails server -p 3000
```

### 2. Test Order Creation
```bash
# Create an order
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "customer_id": 1,
      "product_name": "Test Book",
      "quantity": 2,
      "price": 29.99
    }
  }'

# Check customer order count
curl http://localhost:3001/api/v1/customers/1
```
