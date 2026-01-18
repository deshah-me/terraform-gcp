<style>
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #333;
  }
  
  .container {
    background: white;
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.3);
  }
  
  h1 {
    color: #667eea;
    border-bottom: 3px solid #764ba2;
    padding-bottom: 10px;
    text-align: center;
  }
  
  h2 {
    color: #764ba2;
    margin-top: 30px;
    padding-left: 10px;
    border-left: 4px solid #667eea;
  }
  
  h3 {
    color: #667eea;
    margin-top: 20px;
  }
  
  .command-box {
    background: #f7f7f7;
    border-left: 4px solid #667eea;
    padding: 15px;
    margin: 10px 0;
    border-radius: 5px;
    font-family: 'Courier New', monospace;
  }
  
  .warning {
    background: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 15px;
    margin: 15px 0;
    border-radius: 5px;
  }
  
  .success {
    background: #d4edda;
    border-left: 4px solid #28a745;
    padding: 15px;
    margin: 15px 0;
    border-radius: 5px;
  }
  
  .info {
    background: #d1ecf1;
    border-left: 4px solid #17a2b8;
    padding: 15px;
    margin: 15px 0;
    border-radius: 5px;
  }
  
  code {
    background: #f4f4f4;
    padding: 2px 6px;
    border-radius: 3px;
    color: #d63384;
    font-family: 'Courier New', monospace;
  }
  
  pre {
    background: #2d2d2d;
    color: #f8f8f2;
    padding: 15px;
    border-radius: 5px;
    overflow-x: auto;
  }
  
  pre code {
    background: transparent;
    color: #f8f8f2;
  }
  
  .step {
    background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 10px 20px;
    border-radius: 25px;
    display: inline-block;
    margin: 10px 0;
    font-weight: bold;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 15px 0;
  }
  
  th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #ddd;
  }
  
  th {
    background: #667eea;
    color: white;
  }
  
  tr:hover {
    background: #f5f5f5;
  }
</style>

<div class="container">

# 🚀 PostgreSQL on GCP - Deployment Guide

<div class="info">
📅 <strong>Created:</strong> January 18, 2026<br>
🏗️ <strong>Infrastructure:</strong> Terraform + Google Cloud Platform<br>
🗄️ <strong>Database:</strong> PostgreSQL 15
</div>

---

## 🎯 Quick Start Commands

<div class="step">Step 1: Initialize Terraform</div>

```bash
terraform init
```

<div class="success">
✅ This downloads the required providers (Google Cloud & Random)
</div>

<div class="step">Step 2: Format & Validate</div>

```bash
# Format configuration files
terraform fmt

# Validate configuration
terraform validate
```

<div class="step">Step 3: Review Changes</div>

```bash
terraform plan
```

<div class="info">
💡 <strong>Tip:</strong> Review the plan carefully to see what resources will be created
</div>

<div class="step">Step 4: Deploy Infrastructure</div>

```bash
terraform apply
```

Or for auto-approval:

```bash
terraform apply --auto-approve
```

---

## 🔐 Retrieve Credentials

After successful deployment, retrieve your database credentials:

### 📋 Get All Outputs

```bash
terraform output
```

### 🔑 Get Specific Credentials

```bash
# Root password
terraform output root_password

# Application user password
terraform output app_user_password

# Instance IP address
terraform output instance_ip_address

# Connection name (for Cloud SQL Proxy)
terraform output instance_connection_name

# Database name
terraform output database_name

# Service account email
terraform output service_account_email
```

<div class="warning">
⚠️ <strong>Security Warning:</strong> Never commit these credentials to version control!
</div>

---

## 🔌 Connect to PostgreSQL

### Method 1: Direct Connection (Using Public IP)

```bash
psql -h <INSTANCE_IP> -U app_user -d my-database
```

Example:
```bash
psql -h 35.123.45.67 -U app_user -d my-database
# Enter password when prompted
```

### Method 2: Cloud SQL Proxy (Recommended)

#### Install Cloud SQL Proxy

**Windows:**
```powershell
# Download Cloud SQL Proxy
curl -o cloud-sql-proxy.exe https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.x64.exe
```

**Linux/Mac:**
```bash
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy
```

#### Start Proxy

```bash
# Get connection name first
terraform output instance_connection_name

# Start proxy (Windows)
cloud-sql-proxy.exe <CONNECTION_NAME>

# Start proxy (Linux/Mac)
./cloud-sql-proxy <CONNECTION_NAME>
```

#### Connect via Proxy

```bash
psql -h 127.0.0.1 -U app_user -d my-database
```

### Method 3: Connection String

```bash
postgresql://app_user:<PASSWORD>@<INSTANCE_IP>:5432/my-database
```

---

## 🧪 Test SQL Connection

### Basic Connection Test

```sql
-- Check PostgreSQL version
SELECT version();

-- Check current user
SELECT current_user;

-- List databases
\l

-- Connect to database
\c my-database

-- List tables
\dt

-- Check database size
SELECT pg_size_pretty(pg_database_size('my-database'));
```

### Create Test Table

```sql
-- Create a test table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO users (username, email) 
VALUES 
    ('john_doe', 'john@example.com'),
    ('jane_smith', 'jane@example.com');

-- Query data
SELECT * FROM users;

-- Check table info
\d users
```

### Verify Permissions

```sql
-- Check current user privileges
SELECT 
    grantee, 
    privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name='users';

-- Check database permissions
\du
```

---

## 📊 Monitor Database

### Check Instance Status

```bash
gcloud sql instances describe <INSTANCE_NAME>
```

### View Logs

```bash
gcloud sql operations list --instance=<INSTANCE_NAME>
```

### Check Backups

```bash
gcloud sql backups list --instance=<INSTANCE_NAME>
```

---

## 🔧 Management Commands

### Update Database

```bash
# Modify main.tf and apply changes
terraform apply
```

### View Current State

```bash
terraform show
```

### Refresh State

```bash
terraform refresh
```

### Destroy Infrastructure

<div class="warning">
⚠️ <strong>DANGER:</strong> This will delete all resources!
</div>

```bash
terraform destroy
```

Or with auto-approval:

```bash
terraform destroy --auto-approve
```

---

## 📦 Created Resources

| Resource | Description | Name/ID |
|----------|-------------|---------|
| 🗄️ **Cloud SQL Instance** | PostgreSQL 15 database instance | `postgres-instance-<random>` |
| 📊 **Database** | Application database | `my-database` |
| 👤 **Root User** | PostgreSQL admin user | `postgres` |
| 👤 **App User** | Application user | `app_user` |
| 🔐 **Service Account** | Cloud SQL client service account | `sql-client-sa` |
| 🔑 **IAM Bindings** | Cloud SQL client & editor roles | - |

---

## 🛡️ Security Features

- ✅ Automated daily backups
- ✅ Point-in-time recovery enabled
- ✅ 7-day backup retention
- ✅ Auto-generated strong passwords (16 characters)
- ✅ Service account with least-privilege access
- ✅ IAM-based authentication support

<div class="warning">
⚠️ <strong>Production Setup:</strong>
<ul>
  <li>Change authorized networks from <code>0.0.0.0/0</code> to specific IP ranges</li>
  <li>Enable deletion protection</li>
  <li>Use private IP configuration</li>
  <li>Enable SSL/TLS encryption</li>
  <li>Store credentials in Secret Manager</li>
</ul>
</div>

---

## 🐛 Troubleshooting

### Error: Authentication Failed

```bash
# Check if user exists
gcloud sql users list --instance=<INSTANCE_NAME>

# Reset password if needed
terraform apply -replace="random_password.app_user_password"
```

### Error: Connection Timeout

```bash
# Check firewall rules
gcloud sql instances describe <INSTANCE_NAME> --format="value(settings.ipConfiguration)"

# Check authorized networks in main.tf
```

### Error: Instance Already Exists

```bash
# Import existing instance
terraform import google_sql_database_instance.postgres_instance <INSTANCE_NAME>
```

---

## 📚 Useful PostgreSQL Commands

### Database Operations

```sql
-- Create new database
CREATE DATABASE new_db;

-- Drop database
DROP DATABASE new_db;

-- List all schemas
\dn

-- List all functions
\df
```

### User Management

```sql
-- Create new user
CREATE USER new_user WITH PASSWORD 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE my-database TO new_user;

-- Revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE my-database FROM new_user;

-- Drop user
DROP USER new_user;
```

### Performance Monitoring

```sql
-- Active connections
SELECT * FROM pg_stat_activity;

-- Database statistics
SELECT * FROM pg_stat_database WHERE datname = 'my-database';

-- Table sizes
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## 🎓 Best Practices

1. **🔐 Security**
   - Rotate passwords regularly
   - Use service accounts for application access
   - Enable Cloud SQL Auth Proxy for production
   - Restrict IP ranges in authorized networks

2. **💾 Backups**
   - Test backup restoration regularly
   - Monitor backup success/failure
   - Keep backup retention appropriate for compliance

3. **📊 Monitoring**
   - Set up Cloud Monitoring alerts
   - Monitor connection counts
   - Track query performance
   - Watch disk utilization

4. **💰 Cost Optimization**
   - Use appropriate instance tier for workload
   - Consider Cloud SQL editions (Enterprise, Enterprise Plus)
   - Enable automatic storage increase
   - Schedule instances for non-production environments

---

## 📞 Support & Resources

- 📖 [Google Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- 📖 [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- 📖 [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- 💬 [GCP Community Support](https://cloud.google.com/support)

---

<div class="success">
✨ <strong>Happy Coding!</strong> Your PostgreSQL database is ready to use! 🎉
</div>

</div>
