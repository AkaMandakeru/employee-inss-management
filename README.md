# CrediShop Test Application

A comprehensive Rails application for employee management with salary calculations, reporting, and data visualization.

## 🚀 Features

- **Employee Management**: CRUD operations for employees with nested attributes for addresses and contacts
- **Salary Calculator**: Real-time INSS (Brazilian social security) discount calculation with progressive tax brackets
- **Reports & Analytics**: Visual charts and tables showing employee distribution by salary brackets
- **Responsive UI**: Bootstrap 5.3.8 integration with modern, mobile-friendly design
- **Authentication**: Secure user sessions with bcrypt password hashing
- **Data Visualization**: Chart.js integration for interactive reports
- **Testing**: Comprehensive RSpec test suite with FactoryBot and Shoulda Matchers

## 🛠 Technologies & Gems

### Core Framework
- **Ruby**: 3.2.5
- **Rails**: 8.0.3
- **Database**: PostgreSQL
- **Web Server**: Puma
- **Asset Pipeline**: Propshaft

### Frontend Technologies
- **Bootstrap**: 5.3.8 (CSS Framework)
- **Stimulus.js**: Modest JavaScript framework for Hotwire
- **Chart.js**: Data visualization library
- **Slim**: Template engine (cleaner than ERB)
- **Importmap**: ES modules without bundling

### Key Gems
- **bcrypt**: Secure password hashing
- **will_paginate**: Pagination for large datasets
- **slim-rails**: Slim template integration
- **solid_cache/solid_queue/solid_cable**: Database-backed Rails adapters
- **bootsnap**: Boot time optimization
- **thruster**: HTTP asset caching and compression

### Testing & Development
- **RSpec**: Testing framework
- **FactoryBot**: Test data generation
- **Shoulda Matchers**: RSpec matchers for Rails
- **Faker**: Fake data generation
- **Capybara**: System testing
- **RuboCop**: Code linting
- **Brakeman**: Security vulnerability scanning

### Deployment
- **Kamal**: Docker deployment
- **Docker**: Containerization

## 📋 Prerequisites

### For Regular Setup
- Ruby 3.2.5
- PostgreSQL 15+
- Node.js (for importmap)
- Bundler gem

### For Docker Setup
- Docker & Docker Compose
- Git

## 🚀 Quick Start

### Option 1: Docker Setup (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd credishop_test
   ```

2. **Start the development environment**
   ```bash
   docker compose -f docker-compose.dev.yml up --build -d
   ```

3. **Setup the database**
   ```bash
   docker compose -f docker-compose.dev.yml exec web rails db:create db:migrate db:seed
   ```

4. **Access the application**
   - URL: http://localhost:3000
   - Admin login: `admin@credishop.com` / `admin123`

### Option 2: Regular Setup

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Setup the database**
   ```bash
   rails db:create db:migrate db:seed
   ```

3. **Start the server**
   ```bash
   rails server
   ```

4. **Access the application**
   - URL: http://localhost:3000
   - Admin login: `admin@credishop.com` / `admin123`

## 📊 Database Schema

The application includes the following models:

- **Users**: Authentication with secure passwords
- **Sessions**: User session management
- **Employees**: Employee information with salary and INSS calculations
- **Addresses**: Employee addresses (nested attributes)
- **Contacts**: Employee contact information (phone, email, etc.)

## 🧪 Testing

Run the complete test suite:
```bash
# Docker
docker compose -f docker-compose.dev.yml exec web bundle exec rspec

# Regular
bundle exec rspec
```

## 📈 Reports & Analytics

The application includes comprehensive reporting features:

- **Salary Distribution**: Visual charts showing employee distribution across INSS tax brackets
- **Payroll Analytics**: Total payroll, average salaries, and employee type breakdowns
- **Interactive Charts**: Bar charts and doughnut charts powered by Chart.js

## 🔧 Development Commands

### Docker Commands
```bash
# View logs
docker compose -f docker-compose.dev.yml logs -f web

# Rails console
docker compose -f docker-compose.dev.yml exec web rails console

# Run specific tests
docker compose -f docker-compose.dev.yml exec web bundle exec rspec spec/models/

# Stop services
docker compose -f docker-compose.dev.yml down
```

### Regular Commands
```bash
# Rails console
rails console

# Run migrations
rails db:migrate

# Reset database
rails db:drop db:create db:migrate db:seed

# Run specific tests
bundle exec rspec spec/controllers/
```

## 🐳 Production Deployment

For production deployment using Docker:

1. **Set Rails master key**
   ```bash
   export RAILS_MASTER_KEY=$(cat config/master.key)
   ```

2. **Start production environment**
   ```bash
   docker compose up --build -d
   ```

3. **Setup production database**
   ```bash
   docker compose exec web rails db:create db:migrate db:seed
   ```

## 📝 Sample Data

The application comes with seed data including:
- 15 realistic Brazilian employees with complete information
- Multiple addresses and contacts per employee
- Calculated INSS discounts based on salary brackets
- Admin user for testing

## 🔐 Security Features

- Secure password hashing with bcrypt
- Session-based authentication
- SQL injection protection with ActiveRecord
- XSS protection with Rails sanitization
- CSRF protection enabled

## 📱 Responsive Design

The application is fully responsive and works on:
- Desktop computers
- Tablets
- Mobile phones
- Various screen sizes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Note**: This application is a test project demonstrating modern Rails development practices with Docker containerization, comprehensive testing, and responsive UI design.
