# Simple Microservices Architecture Demo

## 🎯 What We're Building

A **super simple** e-commerce system with 3 microservices:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Product   │    │    Order    │    │   Payment   │
│  Service    │    │   Service   │    │   Service   │
│             │    │             │    │             │
│ Port: 5001  │    │ Port: 5002  │    │ Port: 5003  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                    ┌─────────────┐
                    │   Gateway   │
                    │  (Frontend) │
                    │ Port: 5000  │
                    └─────────────┘
```

## 🚀 Quick Start

```powershell
cd simple-demo
.\start-demo.ps1
```

Then visit: **http://localhost:5000**

## 📋 What Each Service Does

### 1. Product Service (Port 5001)
- **GET /api/products** - List all products
- **GET /api/products/{id}** - Get specific product

### 2. Order Service (Port 5002)  
- **POST /api/orders** - Create new order
- **GET /api/orders/{id}** - Get order details

### 3. Payment Service (Port 5003)
- **POST /api/payments** - Process payment
- **GET /api/payments/{id}** - Get payment status

### 4. Gateway (Port 5000)
- **Frontend** - Simple web page
- **Routes** - Forwards requests to appropriate services

## 🔍 Key Microservices Concepts Demonstrated

✅ **Service Independence** - Each service runs separately  
✅ **API Communication** - Services talk via HTTP APIs  
✅ **Single Responsibility** - Each service has one job  
✅ **Decentralized Data** - Each service has its own data  
✅ **Gateway Pattern** - Single entry point for clients  

## 📁 Project Structure

```
simple-demo/
├── README.md (this file)
├── start-demo.ps1           # Launch all services
├── stop-demo.ps1            # Stop all services
├── gateway/                 # Frontend + API Gateway
│   ├── Program.cs
│   ├── wwwroot/index.html
│   └── gateway.csproj
├── product-service/         # Product microservice
│   ├── Program.cs
│   └── product-service.csproj
├── order-service/           # Order microservice
│   ├── Program.cs
│   └── order-service.csproj
└── payment-service/         # Payment microservice
    ├── Program.cs
    └── payment-service.csproj
```

## 🎓 Learning Points

### Before (Monolith)
```
┌─────────────────────────────┐
│        One Big App          │
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │Prod │ │Order│ │Pay  │   │
│  │ucts │ │ers  │ │ment │   │
│  └─────┘ └─────┘ └─────┘   │
│      One Database          │
└─────────────────────────────┘
```

### After (Microservices)
```
┌─────────┐  ┌─────────┐  ┌─────────┐
│Product  │  │ Order   │  │Payment  │
│Service  │  │Service  │  │Service  │
│   +     │  │   +     │  │   +     │
│  Data   │  │  Data   │  │  Data   │
└─────────┘  └─────────┘  └─────────┘
```

## 🔧 How It Works

1. **User visits** http://localhost:5000
2. **Gateway serves** the web page
3. **User clicks** "Get Products"
4. **Gateway calls** Product Service (5001)
5. **Product Service** returns product list
6. **Gateway shows** products to user

## 💡 Try These Demos

1. **View Products**: Click "Get Products" button
2. **Create Order**: Click "Create Order" button  
3. **Process Payment**: Click "Process Payment" button
4. **Stop a Service**: Stop one service and see what happens
5. **Check Logs**: See how services communicate

## 🎯 Key Benefits Shown

- **Scalability**: Can run multiple instances of busy services
- **Technology Freedom**: Each service could use different tech
- **Team Independence**: Different teams can work on different services
- **Fault Isolation**: If one service fails, others keep working
- **Deployment Independence**: Deploy services separately

## 🔍 What's Missing (For Simplicity)

- Database (using in-memory data)
- Authentication/Security
- Service Discovery
- Load Balancing
- Monitoring/Logging
- Error Handling
- Data Consistency

*This is intentionally simple to focus on core concepts!*
