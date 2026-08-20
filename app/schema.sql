CREATE TABLE IF NOT EXISTS security_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id VARCHAR(36) NOT NULL UNIQUE,
    severity VARCHAR(20) NOT NULL,
    source VARCHAR(50),
    type VARCHAR(50),
    title VARCHAR(255),
    description TEXT,
    source_ip VARCHAR(45),
    username VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_security_events_created_at (created_at),
    INDEX idx_security_events_severity (severity)
);
