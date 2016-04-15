INSERT INTO member (login, name, admin, password) VALUES ('admin', 'Administrator', TRUE, '$1$/EMPTY/$NEWt7XJg2efKwPm4vectc1');
UPDATE member SET last_activity=created WHERE login='admin';
UPDATE member SET activated=created WHERE login='admin';
UPDATE member SET active=true WHERE login='admin';
