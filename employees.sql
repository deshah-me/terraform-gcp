-- ====================================
-- Employee Database Setup Script
-- ====================================

-- Drop table if exists (for clean setup)
DROP TABLE IF EXISTS employees CASCADE;

-- Create employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    job_title VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL CHECK (salary > 0),
    manager_id INTEGER REFERENCES employees(employee_id),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'USA',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on email for faster lookups
CREATE INDEX idx_employees_email ON employees(email);

-- Create index on department for reporting
CREATE INDEX idx_employees_department ON employees(department);

-- Create index on manager_id for hierarchy queries
CREATE INDEX idx_employees_manager_id ON employees(manager_id);

-- Insert sample employee data
INSERT INTO employees (first_name, last_name, email, phone, hire_date, job_title, department, salary, manager_id, address, city, state, zip_code, country) 
VALUES 
    -- CEO (no manager)
    ('John', 'Smith', 'john.smith@company.com', '555-0101', '2020-01-15', 'Chief Executive Officer', 'Executive', 250000.00, NULL, '123 Executive Dr', 'New York', 'NY', '10001', 'USA'),
    
    -- Department Heads (reporting to CEO)
    ('Sarah', 'Johnson', 'sarah.johnson@company.com', '555-0102', '2020-03-01', 'VP of Engineering', 'Engineering', 180000.00, 1, '456 Tech Ave', 'San Francisco', 'CA', '94102', 'USA'),
    ('Michael', 'Williams', 'michael.williams@company.com', '555-0103', '2020-04-15', 'VP of Sales', 'Sales', 175000.00, 1, '789 Sales Blvd', 'Chicago', 'IL', '60601', 'USA'),
    ('Emily', 'Brown', 'emily.brown@company.com', '555-0104', '2020-06-01', 'VP of Human Resources', 'HR', 160000.00, 1, '321 People St', 'Austin', 'TX', '78701', 'USA'),
    
    -- Engineering Team
    ('David', 'Martinez', 'david.martinez@company.com', '555-0105', '2021-01-10', 'Senior Software Engineer', 'Engineering', 135000.00, 2, '111 Code Ln', 'San Francisco', 'CA', '94103', 'USA'),
    ('Jessica', 'Garcia', 'jessica.garcia@company.com', '555-0106', '2021-03-15', 'Software Engineer', 'Engineering', 110000.00, 2, '222 Dev Way', 'San Francisco', 'CA', '94104', 'USA'),
    ('Daniel', 'Rodriguez', 'daniel.rodriguez@company.com', '555-0107', '2021-05-20', 'DevOps Engineer', 'Engineering', 125000.00, 2, '333 Cloud Dr', 'Seattle', 'WA', '98101', 'USA'),
    ('Ashley', 'Wilson', 'ashley.wilson@company.com', '555-0108', '2022-02-01', 'Junior Software Engineer', 'Engineering', 85000.00, 2, '444 Junior Ave', 'San Francisco', 'CA', '94105', 'USA'),
    
    -- Sales Team
    ('Christopher', 'Anderson', 'christopher.anderson@company.com', '555-0109', '2021-02-15', 'Senior Sales Manager', 'Sales', 95000.00, 3, '555 Deal St', 'Chicago', 'IL', '60602', 'USA'),
    ('Amanda', 'Thomas', 'amanda.thomas@company.com', '555-0110', '2021-07-01', 'Sales Representative', 'Sales', 75000.00, 3, '666 Revenue Rd', 'Boston', 'MA', '02101', 'USA'),
    ('Matthew', 'Taylor', 'matthew.taylor@company.com', '555-0111', '2022-01-10', 'Sales Representative', 'Sales', 70000.00, 3, '777 Quota Ln', 'Miami', 'FL', '33101', 'USA'),
    
    -- HR Team
    ('Jennifer', 'Moore', 'jennifer.moore@company.com', '555-0112', '2021-04-01', 'HR Manager', 'HR', 90000.00, 4, '888 People Ave', 'Austin', 'TX', '78702', 'USA'),
    ('Joshua', 'Jackson', 'joshua.jackson@company.com', '555-0113', '2021-09-15', 'Recruiter', 'HR', 65000.00, 4, '999 Talent Way', 'Austin', 'TX', '78703', 'USA'),
    
    -- Support Team
    ('Stephanie', 'White', 'stephanie.white@company.com', '555-0114', '2022-03-01', 'Customer Support Manager', 'Support', 85000.00, 1, '101 Help Desk Dr', 'Denver', 'CO', '80201', 'USA'),
    ('Ryan', 'Harris', 'ryan.harris@company.com', '555-0115', '2022-06-15', 'Customer Support Specialist', 'Support', 55000.00, 14, '202 Support St', 'Denver', 'CO', '80202', 'USA');

-- Create a trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_employees_updated_at 
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Display summary
SELECT 
    department,
    COUNT(*) as employee_count,
    ROUND(AVG(salary), 2) as avg_salary,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;

-- Display all employees with their managers
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.job_title,
    e.department,
    e.salary,
    m.first_name || ' ' || m.last_name as manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.department, e.salary DESC;
