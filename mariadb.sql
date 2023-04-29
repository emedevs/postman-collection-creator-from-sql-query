SET @database_name = 'experience_system';

SET @table_query = CONCAT(
  'SELECT ',
  '  CONCAT(\'{"name":"\', name, \'","item": [',
  '  {"name":"GET","request":{"url":"\', request_url, \'","method":"GET"},"response":[]},',
  '  {"name":"POST","request":{"url":"\', request_url, \'","method":"POST"},"response":[]},',
  '  {"name":"PUT","request":{"url":"\', request_url, \'","method":"PUT"},"response":[]},',
  '  {"name":"PATCH","request":{"url":"\', request_url, \'","method":"PATCH"},"response":[]}',
  ']} \') AS item ',
  'FROM (',
  '  SELECT TABLE_NAME AS name, CONCAT(\'{{base_url}}/\', REPLACE(TABLE_NAME, \'_\', \'-\')) AS request_url ',
  '  FROM INFORMATION_SCHEMA.TABLES ',
  '  WHERE TABLE_TYPE = \'BASE TABLE\' AND TABLE_SCHEMA = ?',
  ') AS t'
);

SET @stmt = @table_query;
PREPARE stmt FROM @stmt;
EXECUTE stmt USING @database_name;
DEALLOCATE PREPARE stmt;

SET @json = CONCAT(
  '{',
  '  "info": {',
  '    "_postman_id": "XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",',
  '    "name": "Table Endpoints",',
  '    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"',
  '  },',
  '  "item": [',
  '    ', (SELECT GROUP_CONCAT(item SEPARATOR ',\n')
            FROM (SELECT TABLE_NAME AS name,
                         CONCAT('{{base_url}}/', REPLACE(TABLE_NAME, '_', '-')) AS request_url,
                         CONCAT('{"name":"', TABLE_NAME, '", "item": [',
                                '{"name":"GET","request":{"url":"{{base_url}}/', REPLACE(TABLE_NAME, '_', '-'), '","method":"GET"},"response":[]},',
                                '{"name":"POST","request":{"url":"{{base_url}}/', REPLACE(TABLE_NAME, '_', '-'), '","method":"POST"},"response":[]},',
                                '{"name":"PUT","request":{"url":"{{base_url}}/', REPLACE(TABLE_NAME, '_', '-'), '","method":"PUT"},"response":[]},',
                                '{"name":"PATCH","request":{"url":"{{base_url}}/', REPLACE(TABLE_NAME, '_', '-'), '","method":"PATCH"},"response":[]}',
                                ']}') AS item
                  FROM INFORMATION_SCHEMA.TABLES
                  WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = @database_name) AS t), '',
  '  ]',
  '}'
);

SELECT @json AS postman_collection;
